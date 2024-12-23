from fastapi import FastAPI, HTTPException, File, UploadFile
from pydantic import BaseModel
import numpy as np
import tensorflow as tf
from keras.models import load_model
import uvicorn
from PIL import Image
import io
import os
from fastapi.middleware.cors import CORSMiddleware

# Initialiser l'application FastAPI
app = FastAPI(title="Fashion Classification API")

# Configurer CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, spécifiez les origines exactes
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Obtenir le chemin du dossier parent
parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# Construire le chemin vers le modèle
MODEL_PATH = os.path.join(parent_dir, "assets", "clothes_model.h5")
model = load_model(MODEL_PATH)
# Recompiler le modèle
model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# Définir les classes
class_names = [
    'Haut', 'Pantalon', 'Pull', 'Robe', 'Manteau',
    'Sandale', 'Chemise', 'Basket', 'Sac', 'Bottine'
  ]

# Prétraiter l'image
def preprocess_image(image_data):
    # Convertir les bytes en image
    image = Image.open(io.BytesIO(image_data))
    
    # Convertir en niveau de gris si ce n'est pas déjà le cas
    image = image.convert('L')
    
    # Redimensionner à 28x28 pixels (taille attendue par le modèle)
    image = image.resize((28, 28))
    
    # Convertir en array et normaliser
    image_array = np.array(image)
    image_array = image_array.astype('float32') / 255.0
    
    # Ajouter la dimension du batch
    image_array = np.expand_dims(image_array, axis=0)
    
    return image_array

# API input format
class PredictionResponse(BaseModel):
    predicted_class: str
    confidence: float
    class_index: int

# API endpoints
@app.get("/")
def home():
    return {"message": "Welcome to the Fashion Classification API!"}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        # Vérifier le type MIME
        print(f"Received file: {file.filename}")
        print(f"Content type: {file.content_type}")
        
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="File must be an image")
        
        # Lire le contenu
        contents = await file.read()
        print(f"File size: {len(contents)} bytes")
        
        # Prétraiter l'image
        processed_image = preprocess_image(contents)
        
        # Faire la prédiction
        predictions = model.predict(processed_image)
        predicted_class_index = np.argmax(predictions[0])
        confidence = float(predictions[0][predicted_class_index])
        
        return {
            "predicted_class": class_names[predicted_class_index],
            "confidence": confidence,
            "class_index": int(predicted_class_index)
        }
        
    except Exception as e:
        print(f"Error processing image: {str(e)}")
        raise HTTPException(status_code=400, detail=f"Failed to process image: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="localhost", port=8000)
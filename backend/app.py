from flask import Flask, request, jsonify
import requests
import cv2
import numpy as np
from pyzbar.pyzbar import decode
import io
from PIL import Image

app = Flask(__name__)

@app.route('/process_image', methods=['POST'])
def process_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    image_file = request.files['image']
    image = Image.open(image_file.stream)
    # Process the image (e.g., decode barcode)
    decoded_objects = decode(image)
    result = [{'type': obj.type, 'data': obj.data.decode('utf-8')} for obj in decoded_objects]

    return jsonify({'decoded_objects': result})

if __name__ == '__main__':
    app.run(debug=True)
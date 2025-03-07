import requests

# Path to the image file
image_path = 'baking_soda.jpg'

# URL of the Flask API endpoint
url = 'http://127.0.0.1:5000/nutrition'

# Open the image file in binary mode
with open(image_path, 'rb') as image_file:
    # Create a dictionary with the image file
    files = {'image': image_file}
    
    # Send a POST request to the Flask API
    response = requests.post(url, files=files)
    
    # Print the response from the API
    print(response.json())
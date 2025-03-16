import os
import json
import requests
from dotenv import load_dotenv

def load_user_profile(file_path):
    """Loads user profile from a text file."""
    with open(file_path, 'r') as file:
        data = file.readlines()
    
    profile = {}
    for line in data:
        key, value = line.strip().split(': ', 1)
        profile[key] = value
    return profile

def calculate_health_score(analysis_result, profile):
    """Determines health score based on identified risks."""
    health_score = 10  # Default full score
    if any(allergy in analysis_result for allergy in profile.get('Allergies', '').split(', ')):
        return 0  # Severe penalty for allergens
    if "High Sugar" in analysis_result or "High Fat" in analysis_result:
        health_score -= 3
    if "Processed Food" in analysis_result:
        health_score -= 2
    return max(health_score, 1)  # Ensure the score doesn't go below 1

def generate_prompt(profile, scanned_text):
    """Generates a structured prompt for food label analysis."""
    return f"""
    You are a chronic illness doctor who is sweet and motivating. Your tone is kind yet professional, offering clear, supportive, and uplifting guidance to patients managing chronic conditions.
    
    Analyze the following food label for a user with the given profile. Identify:
    - Any **allergens** present (highlight in red).
    - Any **ingredients that violate food preferences** (highlight in red).
    - Any **ingredients that trigger dietary restrictions** (highlight in red).
    - Calculate the **nutrition score** of the product.
    - Rate the **healthiness of the product** on a scale of 1 to 10.
    - Provide a **brief recommendation** on whether the user should consume this or avoid it.
    - Suggest **alternative products** that are healthier.
    - Recommend trending **homemade recipes** that suit the user's dietary needs.
    - Provide effective **at-home exercises** and **lifestyle tips** for managing their chronic condition.
    
    **User Profile:**
    - Age: {profile.get('Age', 'Unknown')}
    - Weight: {profile.get('Weight', 'Unknown')}
    - Gender: {profile.get('Gender', 'Unknown')}
    - Chronic Illness: {profile.get('Chronic Illness', 'None')}
    - Allergies: {profile.get('Allergies', 'None')}
    - Food Triggers: {profile.get('Food Triggers', 'None')}
    - Dietary Preferences: {profile.get('Dietary Preferences', 'None')}
    
    **Scanned Text:** "{scanned_text}"
    """

def send_to_gemini(prompt):
    """Sends the prompt to Gemini LLM and retrieves the response."""
    load_dotenv()
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        return "Error: Missing API Key"
    
    api_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    payload = {"contents": [{"parts": [{"text": prompt}]}]}
    headers = {'Content-Type': 'application/json'}
    response = requests.post(f"{api_url}?key={api_key}", headers=headers, json=payload)
    
    if response.status_code == 200:
        response_data = response.json()
        return response_data.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "No response received")
    else:
        return f"Error: {response.status_code}"

def main():
    user_profile_path = "user_profile.txt"
    scanned_text_path = "scanned_text.txt"
    output_path = "output.txt"
    
    user_profile = load_user_profile(user_profile_path)
    with open(scanned_text_path, 'r') as file:
        scanned_text = file.read().strip()
    
    prompt = generate_prompt(user_profile, scanned_text)
    response = send_to_gemini(prompt)
    
    health_score = calculate_health_score(response, user_profile)
    
    final_output = f"\n### Food Analysis Report ###\n\n{response}\n\n**Health Score:** {health_score}/10\n"
    
    with open(output_path, 'w') as output_file:
        output_file.write(final_output)
    
    print("Analysis completed. Output saved in output.txt")

if __name__ == "__main__":
    main()
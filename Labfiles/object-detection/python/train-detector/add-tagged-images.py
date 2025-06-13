from pathlib import Path
from azure.cognitiveservices.vision.customvision.training import CustomVisionTrainingClient
from azure.cognitiveservices.vision.customvision.training.models import ImageFileCreateBatch, ImageFileCreateEntry, Region
from msrest.authentication import ApiKeyCredentials
import time
import json
import os

def main():
    from dotenv import load_dotenv
    global training_client
    global custom_vision_project

    # Clear the console
    os.system('cls' if os.name=='nt' else 'clear')

    try:
        # Get Configuration Settings
        load_dotenv()
        training_endpoint = os.getenv('TrainingEndpoint')
        training_key = os.getenv('TrainingKey')
        project_id = os.getenv('ProjectID')

        # Authenticate a client for the training API
        credentials = ApiKeyCredentials(in_headers={"Training-key": training_key})
        training_client = CustomVisionTrainingClient(training_endpoint, credentials)

        # Get the Custom Vision project
        custom_vision_project = training_client.get_project(project_id)

        # Upload and tag images
        images_folder = Path(__file__).parent / 'images'
        if not images_folder.exists():
            print(f"Images folder '{images_folder}' does not exist.")
            return
        Upload_Images(images_folder)
    except Exception as ex:
        print(ex)



def Upload_Images(folder):
    print("Uploading images...")

    # Get the tags defined in the project
    tags = training_client.get_tags(custom_vision_project.id)

    # Create a list of images with tagged regions
    tagged_images_with_regions = []
    tagged_images_json = folder.parent / 'tagged-images.json'
    if not tagged_images_json.exists():
        print(f"Tagged images JSON file '{tagged_images_json}' does not exist.")
        return

    # Get the images and tagged regions from the JSON file
    with open(tagged_images_json, 'r') as json_file:
        tagged_images = json.load(json_file)
        for i, image in enumerate(tagged_images['files']):
            # Get the filename
            file = image['filename']
            # Get the tagged regions
            regions = []
            print(f"Processing image {i+1}/{len(tagged_images['files'])}: {file}")
            try:
                for tag in image['tags']:
                    tag_name = tag['tag']
                    # Look up the tag ID for this tag name
                    tag_id = next(t for t in tags if t.name == tag_name).id
                    # Add a region for this tag using the coordinates and dimensions in the JSON
                    regions.append(Region(tag_id=tag_id, left=tag['left'],top=tag['top'],width=tag['width'],height=tag['height']))
                # Add the image and its regions to the list
                print(f"Adding image {file} with {len(regions)} regions.")
                # Open the image file and read its contents
                with open(os.path.join(folder,file), mode="rb") as image_data:
                    tagged_images_with_regions.append(ImageFileCreateEntry(name=file, contents=image_data.read(), regions=regions))
                print(f"Image {file} processed.")
            except Exception as e:
                print(f"Error processing image {file}: {e}")

    # Upload the list of images as a batch
    upload_result = training_client.create_images_from_files(custom_vision_project.id, ImageFileCreateBatch(images=tagged_images_with_regions))
    # Check for failure
    if not upload_result.is_batch_successful:
        print("Image batch upload failed.")
        for image in upload_result.images:
            print("Image status: ", image.status)
    else:
        print("Images uploaded.")

if __name__ == "__main__":
    main()
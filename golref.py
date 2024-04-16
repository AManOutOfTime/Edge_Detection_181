import cv2
import numpy as np

def grayscale(image):
    """Convert image to grayscale"""
    return cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

def blur(image):
    """Apply Gaussian blur to the image"""
    return cv2.GaussianBlur(image, (15, 15), 0)

def edge_detection(image):
    """Detect edges in the image using Canny edge detection"""
    return cv2.Canny(image, 100, 200)

def adjust_contrast(image, contrast):
    """Adjust the contrast of the image"""
    return np.clip((contrast * image + 128 * (1 - contrast)), 0, 255).astype(np.uint8)

def main(input_image_path, output_image_path, modes, contrast_steps=16):
    # Read the input image
    image = cv2.imread(input_image_path)

    # Check if the image is loaded successfully
    if image is None:
        print("Error: Unable to load the image.")
        return

    # Apply selected modes
    for mode in modes:
        if mode == 'grayscale':
            image = grayscale(image)
        elif mode == 'blur':
            image = blur(image)
        elif mode == 'edge_detection':
            image = edge_detection(image)
        else:
            print(f"Warning: Unknown mode '{mode}'. Skipping...")

    # Save the processed image
    cv2.imwrite(output_image_path, image)

    # Apply contrast adjustment
    for i in range(contrast_steps):
        contrast = i / (contrast_steps - 1)  # Adjust contrast from 0 to 1
        adjusted_image = adjust_contrast(image, contrast)
        output_file = output_image_path.replace(".jpg", f"_contrast_{i}.jpg")
        cv2.imwrite(output_file, adjusted_image)

    print("Image processing completed.")

if __name__ == "__main__":
    input_image_path = r"C:\Users\Michael\OneDrive\Documents\eec181\golden_ref\input_test.jpg"  # Path to the input image
    output_image_path = r"C:\Users\Michael\OneDrive\Documents\eec181\golden_ref\output_test.jpg"  # Path to save the processed image
    modes = ['grayscale']  # Modes to activate
    main(input_image_path, output_image_path, modes)

import cv2

def detect_motion(video_path):
    cap = cv2.VideoCapture(video_path)

    # Read the first frame
    ret, prev_frame = cap.read()
    if not ret:
        print("Error: Cannot read video file")
        return

    # Convert frame to grayscale
    prev_gray = cv2.cvtColor(prev_frame, cv2.COLOR_BGR2GRAY)

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Convert current frame to grayscale
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        # Compute absolute difference between current frame and previous frame
        frame_diff = cv2.absdiff(gray, prev_gray)

        # Threshold the difference to get binary image
        _, thresh = cv2.threshold(frame_diff, 30, 255, cv2.THRESH_BINARY)

        # Find contours
        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        # Draw rectangles around the detected motion
        for contour in contours:
            x, y, w, h = cv2.boundingRect(contour)
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

        # Display the resulting frame
        cv2.imshow('Motion Detection', frame)
        if cv2.waitKey(30) & 0xFF == ord('q'):
            break

        # Update previous frame
        prev_gray = gray.copy()

    # Release video capture and close all windows
    cap.release()
    cv2.destroyAllWindows()

# Example usage
video_path = r"C:\Users\Michael\OneDrive\Documents\eec181\motion_detect\y2mate.is_-_Airplane_2D_Animation_video_Point_orient_animation_video_2D_animation_Motion_Graphic_-9HqJlhF4mDs-480pp-1713228980.mp4"
detect_motion(video_path)
from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
import numpy as np
import os
import plotly.graph_objects as go
import threading

app = Flask(__name__)

# Enable CORS
CORS(app)

# Function to convert RGB to Hex
def rgb_to_hex(r, g, b):
    return f"#{int(r):02X}{int(g):02X}{int(b):02X}"

# Cube size and resolution
cube_size = 255  # RGB range (0-255)
resolution = 16  # Number of points per axis

# Generate RGB cube points
grid = np.linspace(0, cube_size, resolution)
x, y, z = np.meshgrid(grid, grid, grid)
x_flat, y_flat, z_flat = x.flatten(), y.flatten(), z.flatten()

# Normalize RGB values and calculate hex codes
r_flat, g_flat, b_flat = x_flat / cube_size, y_flat / cube_size, z_flat / cube_size
hex_codes = [rgb_to_hex(int(255 * r), int(255 * g), int(255 * b)) for r, g, b in zip(r_flat, g_flat, b_flat)]

# Define the path for saving the HTML file in Flutter's assets directory
html_file_path = "/home/amamul/Desktop/rgbcube/assets/rgb_cube_3d.html"

# Ensure the 'assets' directory exists
os.makedirs(os.path.dirname(html_file_path), exist_ok=True)

# Save the 3D RGB Cube visualization as an HTML file
def save_rgb_cube_html(highlight_x=0, highlight_y=0, highlight_z=0):
    fig = go.Figure()

    # Add RGB cube points
    fig.add_trace(go.Scatter3d(
        x=x_flat, y=y_flat, z=z_flat,
        mode='markers',
        marker=dict(size=5, color=np.array([r_flat, g_flat, b_flat]).T, opacity=0.7),
        name='RGB Cube',
        hovertemplate="RGB: (%{x}, %{y}, %{z})<br>Hex: %{text}<extra></extra>",
        text=hex_codes
    ))

    # Highlight the selected point
    fig.add_trace(go.Scatter3d(
        x=[highlight_x], y=[highlight_y], z=[highlight_z],
        mode='markers',
        marker=dict(size=10, color='black', opacity=1.0),
        name='Highlight',
        hovertemplate="Highlighted Point: (%{x}, %{y}, %{z})<extra></extra>"
    ))

    # Update layout for better visualization
    fig.update_layout(
        title="3D RGB Cube",
        scene=dict(
            xaxis_title='Red (R)',
            yaxis_title='Green (G)',
            zaxis_title='Blue (B)',
            xaxis=dict(range=[0, cube_size], showgrid=False),
            yaxis=dict(range=[0, cube_size], showgrid=False),
            zaxis=dict(range=[0, cube_size], showgrid=False)
        ),
        margin=dict(l=0, r=0, b=0, t=40),
        showlegend=True
    )

    # Save the figure as an HTML file
    fig.write_html(html_file_path)
    print(f"3D RGB Cube HTML saved to {html_file_path}")

# Flask route to receive RGB or Hex coordinates
@app.route('/log_color', methods=['POST'])
def log_color():
    data = request.get_json()
    input_rgb = data.get('value', '(0,0,0)')
    color_type = data.get('type', 'rgb')

    # Extract RGB values from input
    try:
        if color_type == 'rgb':
            input_r, input_g, input_b = map(int, input_rgb.strip('()').split(','))
            if not (0 <= input_r <= 255 and 0 <= input_g <= 255 and 0 <= input_b <= 255):
                raise ValueError("RGB values must be between 0 and 255.")
        elif color_type == 'hex':
            if input_rgb.startswith('#') and len(input_rgb) == 7:
                input_r = int(input_rgb[1:3], 16)
                input_g = int(input_rgb[3:5], 16)
                input_b = int(input_rgb[5:7], 16)
            else:
                raise ValueError("Invalid Hex format. Use #RRGGBB.")
        else:
            raise ValueError("Invalid color type. Use 'rgb' or 'hex'.")
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

    # Calculate the closest point in the cube
    distances = np.sqrt((x_flat - input_r)**2 + (y_flat - input_g)**2 + (z_flat - input_b)**2)
    min_index = np.argmin(distances)
    highlight_x, highlight_y, highlight_z = x_flat[min_index], y_flat[min_index], z_flat[min_index]

    print(f"Received {color_type.upper()} color: ({input_r}, {input_g}, {input_b})")
    print(f"Closest point in RGB Cube: ({highlight_x}, {highlight_y}, {highlight_z})")

    # Save the HTML file with the highlighted point
    save_rgb_cube_html(highlight_x, highlight_y, highlight_z)

    return jsonify({
        "message": "RGB Cube updated successfully!",
        "highlight": [highlight_x, highlight_y, highlight_z]
    }), 200

# Function to run the Flask app
def run_flask():
    app.run(debug=False, host='0.0.0.0', port=5002)

# Main process
if __name__ == '__main__':
    # Generate the initial RGB Cube HTML with default highlight at (0, 0, 0)
    print("Generating initial RGB Cube HTML...")
    save_rgb_cube_html()

    # Start the Flask server in a separate thread
    print("Starting Flask server on port 5002...")
    flask_thread = threading.Thread(target=run_flask)
    flask_thread.daemon = True  # Ensure the thread closes when the program exits
    flask_thread.start()

    # Keep the program running
    flask_thread.join()
import plotly.graph_objects as go
import numpy as np

# Function to convert RGB to Hex
def rgb_to_hex(r, g, b):
    return f"#{int(r):02X}{int(g):02X}{int(b):02X}"

# Cube size and resolution
cube_size = 255  # RGB range (0-255)
resolution = 16  # Number of points per axis

# Generate RGB cube points
grid = np.linspace(0, cube_size, resolution)
x, y, z = np.meshgrid(grid, grid, grid)
r, g, b = x / cube_size, y / cube_size, z / cube_size  # Normalize RGB values

# Flatten arrays for scatter plot
x_flat, y_flat, z_flat = x.flatten(), y.flatten(), z.flatten()

# Calculate hex codes for each point
hex_codes = [
    rgb_to_hex(int(255 * r.flatten()[i]), int(255 * g.flatten()[i]), int(255 * b.flatten()[i]))
    for i in range(len(r.flatten()))
]

# Create the figure
fig = go.Figure()

# Add the RGB cube with hover displaying RGB coordinates and Hex code
fig.add_trace(go.Scatter3d(
    x=x_flat, y=y_flat, z=z_flat,
    mode='markers',
    marker=dict(size=3, color=np.array([r.flatten(), g.flatten(), b.flatten()]).T),
    name='RGB Cube',
    hovertemplate="RGB: (%{x}, %{y}, %{z})<br>Hex: %{text}<extra></extra>",  # Hover showing RGB coordinates and Hex code
    text=hex_codes  # Show hex codes on hover
))

# Update layout for better visualization
fig.update_layout(
    title="3D RGB Cube with RGB Coordinates and Hex Code on Hover",
    scene=dict(
        xaxis_title='X-axis (Red)',
        yaxis_title='Y-axis (Green)',
        zaxis_title='Z-axis (Blue)',
        xaxis=dict(range=[-10, 265]),
        yaxis=dict(range=[-10, 265]),
        zaxis=dict(range=[-10, 265])
    ),
    margin=dict(l=0, r=0, b=0, t=40),
    showlegend=True
)

# Save the figure as an HTML file
fig.write_html("/home/amamul/Desktop/rgbcube/assets/rgb_cube_3d.html")

print("RGB Cube 3D visualization saved as rgb_cube_3d.html")

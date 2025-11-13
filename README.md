A MATLAB-based simulation that models how an interceptor UAV predicts, tracks, and intercepts a moving target UAV using real GPS data, cubic spline trajectory planning, and Proportional Navigation guidance.
The project is built with a modular Object-Oriented Architecture, enabling clean extensibility for future UAV autonomy research.

🚀 Project Overview

This project simulates the real-time interaction between two UAVs:

A target UAV following a flight path derived from GPS data

An interceptor UAV navigating toward the target using PN (Proportional Navigation)

The simulation reconstructs the target UAV’s motion, generates a smooth trajectory using spline interpolation, and guides the interceptor toward interception in 3D space.

🎯 Key Features

GPS → Cartesian conversion for accurate position modeling

Cubic spline interpolation to create a smooth, continuous flight trajectory

Proportional Navigation (PN) for realistic interception behavior

Euler-based integration for updating UAV states

Object-Oriented MATLAB design for scalability and readability

Real-time 3D visualization of the target and interceptor chase

🧩 System Architecture

The project is organized into four main classes:

1. UAVdata

Handles reading raw sensor GPS data, converting coordinates, and computing initial velocities.

2. PathPlanner

Generates smooth target UAV paths using cubic spline interpolation for both positions and velocities.

3. Interceptor

Implements proportional navigation, heading updates, and Euler integration to compute the interceptor’s motion.

4. Simulation

Coordinates the entire process—interpolation, interceptor updates, plotting, and real-time visualization.

🛠️ Technologies & Skills Used

MATLAB

Object-Oriented Programming (OOP)

Numerical Methods

Trajectory Planning

Proportional Navigation

Spline Interpolation

UAV Kinematics & Modeling

3D Simulation & Visualization

📁 Project Structure
Skypath-Interceptor/
│── data/
│   └── sensor_data.csv
│
│── src/
│   ├── UAVdata.m
│   ├── PathPlanner.m
│   ├── Interceptor.m
│   └── Simulation.m
│
│── OEL_Report_Group1.pdf
│── README.md

▶️ How to Run the Simulation

Clone this repository:

git clone https://github.com/<your-username>/Skypath-Interceptor


Open MATLAB.

Add the project folder to the MATLAB path:

addpath(genpath('path_to_repo'));


Place your sensor_data.csv inside the data/ folder.

Run the simulation script:

sim = Simulation(UAVdata_obj, planner_obj, interceptor_obj, dt, axis_handle);
sim.run();


(You can simplify this section if you eventually create a single run script.)

📊 Output

The simulation produces:

A smooth 3D path for the target UAV

The interceptor’s real-time trajectory

Live visualization of the interception attempt

Accurate modeling of navigation behavior

Screenshots or GIFs can be added here later for stronger visual impact.

🔮 Future Enhancements

Wind and aerodynamic modeling

Variable acceleration for both UAVs

Sensor noise + Kalman filtering

Obstacle-aware navigation

Multi-UAV swarm interception

Enhanced UI and playback system

👤 Author

Mahadi Amin
UAV Simulation & Control Systems | MATLAB Developer | Robotics Enthusiast

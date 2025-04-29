#!/usr/bin/env julia

## Import the RobotOS package, which provides all the Julia bindings for ROS
using RobotOS

## Import ROS message types for geometry_msgs, specifically the Twist message type which is used
## to send velocity commands to robots
@rosimport geometry_msgs.msg: Twist

## Generate Julia code for the imported ROS message types
rostypegen()

## Import the Twist message type
import .geometry_msgs.msg: Twist

function move_forward()
    """
    Function that defines the ROS node and publishes velocity commands to move the 
    Fetch robot forward. 
    """
    ## Initialize a ROS node named "move". This registers the node with the ROS master
    init_node("move")
    
    ## Setup a publisher that will send the velocity commands to Fetch
    ## This will publish on a topic called "/cmd_vel" with a message type Twist
    pub = Publisher{Twist}("/cmd_vel", queue_size=1) 
    
    ## Set the loop rate at 10 Hz (10 times per second)
    rate = Rate(10)
    
    ## Provide loginfo for the user
    loginfo("Publishing velocity commands to /cmd_vel")
    loginfo("Press Ctrl+C to stop the node. ")
    
    ## Run the loop until ROS is shut down
    while !is_shutdown()
        ## Make a Twist message. We're going to set all of the elements, since we
        ## can't depend on them defaulting to safe values
        command = Twist()
        
        ## A Twist has three linear velocities (in meters per second), along each of the axes.
        ## For Fetch, it will only pay attention to the x velocity, since it can't
        ## directly move in the y direction or the z direction
        command.linear.x = 0.5
        command.linear.y = 0.0
        command.linear.z = 0.0
        
        ## A Twist also has three rotational velocities (in radians per second).
        ## The Stretch will only respond to rotations around the z (vertical) axis
        command.angular.x = 0.0
        command.angular.y = 0.0
        command.angular.z = 0.0
        
        ## Publish the Twist commands to move the robot forward
        publish(pub, command)
        
        ## Sleep to maintain the desired loop rate (10 Hz)
        rossleep(rate)
    end
end

## This conditional checks if the script is being run directly (not imported)
## If it's being run directly, call the move_stretch function
if !isinteractive()
    move_forward()
end
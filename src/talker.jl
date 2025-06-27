#!/usr/bin/env julia

## Import the RobotOS package, which provides all the Julia bindings for ROS. Essentially
## it enables nodes, topics, messages, and services to funcion withing Julia
using RobotOS

## Import ROS message types using `@rosimport` from std_msgs, specifically the String message type
@rosimport std_msgs.msg.String

## Generate Julia code for the imported ROS message types. This translates ROS message
## definitions into Julia types and functions
rostypegen()

## The StringMsg type is in the current namespace. Julia already has built-in `String` type
## so renamed to `StringMsg`. This is the only incident where you have to rename the message type
using .std_msgs.msg: StringMsg

function talker()
    """
    Function that defines the ROS node and publishes a string message at a rate of 10hz
    """
    ## Initialize a ROS node named "talker". This also gets the node to register with roscore
    init_node("talker") 
    
    ## Create a publisher that will send StringMsg messages on the "chatter" topic. The queue_size means
    ## the size of the outgoing message queue 
    pub = Publisher{StringMsg}("chatter", queue_size=10)
    
    ## Set the loop rate at 10 Hz (10 times per second)
    rate = Rate(10)
    
    ## Run the loop until ROS is shut down
    while !is_shutdown()
        ## Create a string message that includes the current ROS time
        hello_str = "hello world $(to_sec(get_rostime()))"
        
        ## Log the message to the ROS info stream. This will be published in the terminal where the node
        ## is running
        loginfo(hello_str)
        
        ## Publish the string message with the topic name as "chatter" 
        publish(pub, StringMsg(hello_str))
        
        ## Sleep to keep desired loop rate (10 Hz)
        rossleep(rate)
    end
end

## This conditional checks if the script is being run directly (not imported)
## If it's being run directly, call the talker function
if !isinteractive()
    talker()
end
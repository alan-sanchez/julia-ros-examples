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
## so renamed to `StringMsg`
using .std_msgs.msg: StringMsg

function callback(msg)
    """
    Callback function that log/prints the subscribed message

    Parameter:
    - msg (StringMsg): The string message type subscribed from the talker node.
    """
    ## get_caller_id() returns the name of the current ROS node while ms.data accesses the 
    ## string content of the StringMsg
    loginfo("$(RobotOS.get_caller_id()) I heard $(msg.data)")
end

function listener()
    """
    A function that initilizes the node and subscriber
    """
    ## Initialize a ROS node named "talker". This also gets the node to register with roscore
    init_node("listener")  

    ## Create a subscriber to the "chatter" topic. When the message is received, the callback function
    ## will be called with the message as an argument. queue_size will buffer up to 10 messages 
    sub = Subscriber{StringMsg}("chatter", callback; queue_size=10)
    
    ## This allows the node to keep running. Essentially allowing it to process incoming messages
    spin()
end

## This conditional checks if the script is being run directly (not imported)
## If it's being run directly, call the listener function
if !isinteractive()
    listener()
end
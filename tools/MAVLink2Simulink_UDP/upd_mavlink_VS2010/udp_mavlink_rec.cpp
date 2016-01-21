#include "udp_mavlink_rec.hpp"
#include <stdio.h>

/*Construcor*/ 
udp_server::udp_server(int port_no)
  : socket_(service, udp::endpoint(udp::v4(), port_no))
{
  first_timestamp = 0;
  should_end = false;
  socket_.async_receive_from(
      boost::asio::buffer(recv_buffer_), remote_endpoint_,
      boost::bind(&udp_server::handle_receive, this,
        boost::asio::placeholders::error,
        boost::asio::placeholders::bytes_transferred));
  thread = new boost::thread(boost::bind(&boost::asio::io_service::run, &service));
  start_receive();
}

void
udp_server::start_receive()
{ 
  if(!should_end)
  {
    socket_.async_receive_from(
        boost::asio::buffer(recv_buffer_), remote_endpoint_,
        boost::bind(&udp_server::handle_receive, this,
          boost::asio::placeholders::error,
          boost::asio::placeholders::bytes_transferred));
  }
  else
  {
    socket_.close();
    ended = true;
  }
}


void 
udp_server::handle_receive(const boost::system::error_code& error, std::size_t num_bytes)
{

	if (!error || error == boost::asio::error::message_size)
  {
	  
    if(num_bytes > 0)
    {
      mavlink_message_t msg;
      mavlink_status_t status;

      for (int i = 0; i < num_bytes; ++i)
          if (mavlink_parse_char(MAVLINK_COMM_0, recv_buffer_[i], &msg, &status))
            mavlink_msg_decode(msg);
    }
  } 
    start_receive();
}

bool
udp_server::mavlink_msg_decode(const mavlink_message_t & msg)
{
/* Only receive the flexible debug vector for now. The string is used to
 * identify each vector to store them in a std::map                      */
  if (msg.msgid == MAVLINK_MSG_ID_DEBUG_VECT)
  {
    mavlink_debug_vect_t mav_vector;
    mavlink_msg_debug_vect_decode(&msg, &mav_vector);
    
    if (!first_timestamp)
      first_timestamp = mav_vector.time_usec;

    mav_vector.time_usec -= first_timestamp;
    
    /* Add the message to the map. This handles automatically as a 1 element buffer. */
    current_msgs[mav_vector.name] = mav_vector;
    return true;
  }
  else
    return false;
}

bool
udp_server::Close()
{
  service.stop();
  should_end = true;
  thread->detach();
  return ended;
}


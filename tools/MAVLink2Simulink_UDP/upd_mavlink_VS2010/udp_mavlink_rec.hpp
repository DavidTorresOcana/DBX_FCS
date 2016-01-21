#ifndef upd_mavling_header
#define upd_mavling_header

#include <boost/thread.hpp>
#include <boost/array.hpp>
#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/asio.hpp>

#include <map>
#include <string>

#include "mavlink/common/mavlink.h"

using boost::asio::ip::udp;
typedef std::map<std::string, mavlink_debug_vect_t> msgs_map;
class udp_server
{
public:

  udp_server(int port_no);

  const msgs_map * get_latest_data(){ return &current_msgs; }
  
  void start_receive();

  bool Close();

  boost::asio::io_service service;
  
  bool is_open(){return socket_.is_open();}
private:

  void handle_receive(const boost::system::error_code& error, std::size_t num_bytes);
  bool mavlink_msg_decode(const mavlink_message_t & msg);

  udp::socket socket_;
  boost::thread* thread;
  udp::endpoint remote_endpoint_;
  boost::array<char, 128> recv_buffer_;
  bool should_end, ended;

  uint64_t first_timestamp;
  msgs_map current_msgs;
  
};

#endif

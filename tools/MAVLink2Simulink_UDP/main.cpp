#include "udp_mavlink_rec.hpp"
#include <iostream>

int main()
{
  try
  {
    udp_server server( 14550 );

    std::cout << "Server started." << std::endl;
    
    std::string Input;
    while (Input != "exit")
    {
      printf("Press <CR> for polling the latest data\n");
      getline(std::cin, Input);
      printf("Data map has %d types\n", server.get_latest_data());
    }

    server.Close();
  }
  catch (std::exception& e)
  {
    std::cerr << e.what() << std::endl;
  }

  return 0;
}

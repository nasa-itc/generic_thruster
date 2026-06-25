#include <generic_thruster_42_data_provider.hpp>

namespace Nos3
{
    REGISTER_DATA_PROVIDER(Generic_thruster42DataProvider,"GENERIC_THRUSTER_42_PROVIDER");

    extern ItcLogger::Logger *sim_logger;

    Generic_thruster42DataProvider::Generic_thruster42DataProvider(const boost::property_tree::ptree& config) : SimData42SocketProvider(config)
    {
        sim_logger->trace("Generic_thruster42DataProvider::Generic_thruster42DataProvider:  Constructor executed");
        _sc = config.get("simulator.hardware-model.data-provider.spacecraft", 0);
    }

    void Generic_thruster42DataProvider::cmd_thrust(int thr_num, double thr_pct)
    {
        std::stringstream ss;
        ss << "SC[" << _sc << "].Thr[" << thr_num << "].ThrustLevelCmd = " << thr_pct/100.0;
        sim_logger->debug("Generic_thruster42DataProvider::cmd_thrust:  buffer = %s\n", ss.str().c_str());

        send_command_to_socket(ss.str());
    }
}

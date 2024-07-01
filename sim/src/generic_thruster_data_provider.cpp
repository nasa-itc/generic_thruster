#include <generic_thruster_data_provider.hpp>

namespace Nos3
{
    REGISTER_DATA_PROVIDER(Generic_thrusterDataProvider,"GENERIC_THRUSTER_PROVIDER");

    extern ItcLogger::Logger *sim_logger;

    Generic_thrusterDataProvider::Generic_thrusterDataProvider(const boost::property_tree::ptree& config) : SimIDataProvider(config)
    {
        sim_logger->trace("Generic_thrusterDataProvider::Generic_thrusterDataProvider:  Constructor executed");
        _request_count = 0;
    }

    boost::shared_ptr<SimIDataPoint> Generic_thrusterDataProvider::get_data_point(void) const
    {
        sim_logger->trace("Generic_thrusterDataProvider::get_data_point:  Executed");

        /* Prepare the provider data */
        _request_count++;

        /* Request a data point */
        SimIDataPoint *dp = new Generic_thrusterDataPoint(_request_count);

        /* Return the data point */
        return boost::shared_ptr<SimIDataPoint>(dp);
    }
}

#ifndef NOS3_GENERIC_THRUSTERDATAPROVIDER_HPP
#define NOS3_GENERIC_THRUSTERDATAPROVIDER_HPP

#include <boost/property_tree/xml_parser.hpp>
#include <ItcLogger/Logger.hpp>
#include <generic_thruster_data_point.hpp>
#include <sim_i_data_provider.hpp>

namespace Nos3
{
    class Generic_thrusterDataProvider : public SimIDataProvider
    {
    public:
        /* Constructors */
        Generic_thrusterDataProvider(const boost::property_tree::ptree& config);

        /* Accessors */
        boost::shared_ptr<SimIDataPoint> get_data_point(void) const;

    private:
        /* Disallow these */
        ~Generic_thrusterDataProvider(void) {};
        Generic_thrusterDataProvider& operator=(const Generic_thrusterDataProvider&) {return *this;};

        mutable double _request_count;
    };
}

#endif

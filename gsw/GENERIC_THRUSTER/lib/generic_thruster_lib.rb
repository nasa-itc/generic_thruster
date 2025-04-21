# Library for GENERIC_THRUSTER Target
require 'cosmos'
require 'cosmos/script'

# 
# Definitions
# 
GENERIC_THRUSTER_CMD_SLEEP = 0.25
GENERIC_THRUSTER_RESPONSE_TIMEOUT = 5
GENERIC_THRUSTER_TEST_LOOP_COUNT = 1
GENERIC_THRUSTER_DEVICE_LOOP_COUNT = 5


#
# Functions
#
def get_generic_thruster_hk()
    cmd("GENERIC_THRUSTER GENERIC_THRUSTER_REQ_HK")
    wait_check_packet("GENERIC_THRUSTER", "GENERIC_THRUSTER_HK_TLM", 1, GENERIC_THRUSTER_RESPONSE_TIMEOUT)
    sleep(GENERIC_THRUSTER_CMD_SLEEP)
end

def get_generic_thruster_data()
    cmd("GENERIC_THRUSTER GENERIC_THRUSTER_PERCENTAGE_CC")
    wait_check_packet("GENERIC_THRUSTER", "GENERIC_THRUSTER_PERCENTAGE_CC", 1, GENERIC_THRUSTER_RESPONSE_TIMEOUT)
    sleep(GENERIC_THRUSTER_CMD_SLEEP)
end

def generic_thruster_cmd(*command)
    count = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM CMD_COUNT") + 1

    if (count == 256)
        count = 0
    end

    cmd(*command)
    get_generic_thruster_hk()
    current = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM CMD_COUNT");
    if (current != count)
        # Try again
        cmd(*command)
        get_generic_thruster_hk()
        cmd(*command)
        get_generic_thruster_hk()
        current = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM CMD_COUNT");
        if (current != count)
            # Third time's the charm?
            cmd(*command)
            get_generic_thruster_hk()
            current = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM CMD_COUNT");
        end
    end
    check("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM CMD_COUNT >= #{count}")
end

def enable_generic_thruster()
    # Send command
    generic_thruster_cmd("GENERIC_THRUSTER GENERIC_THRUSTER_ENABLE_CC")
    # Confirm
    check("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM DEVICE_ENABLED == 'ENABLED'")    
end

def disable_generic_thruster()
    # Send command
    generic_thruster_cmd("GENERIC_THRUSTER GENERIC_THRUSTER_DISABLE_CC")
    # Confirm
    check("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM DEVICE_ENABLED == 'DISABLED'")    
end

def safe_generic_thruster()
    get_generic_thruster_hk()
    state = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM DEVICE_ENABLED")
    if (state != "DISABLED")
        disable_generic_thruster()
    end
end

def confirm_generic_thruster_data()
    dev_cmd_cnt = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM DEVICE_COUNT")
    dev_cmd_err_cnt = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM DEVICE_ERR_COUNT")

    get_generic_thruster_data()
    # Note these checks assume default simulator configuration
    raw_x = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_DATA_TLM RAW_GENERIC_THRUSTER_X")
    check("GENERIC_THRUSTER GENERIC_THRUSTER_DATA_TLM RAW_GENERIC_THRUSTER_Y >= #{raw_x*2}")
    check("GENERIC_THRUSTER GENERIC_THRUSTER_DATA_TLM RAW_GENERIC_THRUSTER_Z >= #{raw_x*3}")

    get_generic_thruster_hk()
    check("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM DEVICE_COUNT >= #{dev_cmd_cnt}")
    check("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM DEVICE_ERR_COUNT == #{dev_cmd_err_cnt}")
end

def confirm_generic_thruster_data_loop()
    GENERIC_THRUSTER_DEVICE_LOOP_COUNT.times do |n|
        confirm_generic_thruster_data()
    end
end

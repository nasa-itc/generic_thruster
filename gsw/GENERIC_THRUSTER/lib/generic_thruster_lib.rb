# Library for GENERIC_TORQUER Target
require 'cosmos'
require 'cosmos/script'

# 
# Definitions
# 
THRUSTER_CMD_SLEEP = 0.25
THRUSTER_RESPONSE_TIMEOUT = 5
THRUSTER_TEST_LOOP_COUNT = 1
THRUSTER_DEVICE_LOOP_COUNT = 5


#
# Functions
#
def get_thruster_hk()
    cmd("GENERIC_THRUSTER GENERIC_THRUSTER_REQ_HK")
    wait_check_packet("GENERIC_THRUSTER", "GENERIC_THRUSTER_HK_TLM", 1, THRUSTER_RESPONSE_TIMEOUT)
    sleep(THRUSTER_CMD_SLEEP)
end

def get_thruster_data()
    cmd("GENERIC_THRUSTER GENERIC_THRUSTER_PERCENTAGE_CC")
    wait_check_packet("GENERIC_THRUSTER", "GENERIC_THRUSTER_PERCENTAGE_CC", 1, THRUSTER_RESPONSE_TIMEOUT)
    sleep(THRUSTER_CMD_SLEEP)
end

def thruster_cmd(*command)
    count = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM CMD_COUNT") + 1

    if (count == 256)
        count = 0
    end

    cmd(*command)
    get_thruster_hk()
    current = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM CMD_COUNT");
    if (current != count)
        # Try again
        cmd(*command)
        get_thruster_hk()
        cmd(*command)
        get_thruster_hk()
        current = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM CMD_COUNT");
        if (current != count)
            # Third time's the charm?
            cmd(*command)
            get_thruster_hk()
            current = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM CMD_COUNT");
        end
    end
    check("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM CMD_COUNT >= #{count}")
end

def enable_thruster()
    # Send command
    thruster_cmd("GENERIC_THRUSTER GENERIC_THRUSTER_ENABLE_CC")
    # Confirm
    check("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM DEVICE_ENABLED == 'ENABLED'")    
end

def disable_thruster()
    # Send command
    thruster_cmd("GENERIC_THRUSTER GENERIC_THRUSTER_DISABLE_CC")
    # Confirm
    check("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM DEVICE_ENABLED == 'DISABLED'")    
end

def safe_thruster()
    get_generic_thruster_hk()
    state = tlm("GENERIC_THRUSTER GENERIC_THRUSTER_HK_TLM DEVICE_ENABLED")
    if (state != "DISABLED")
        disable_thruster()
    end
end

def confirm_sample_data()
    dev_cmd_cnt = tlm("SAMPLE SAMPLE_HK_TLM DEVICE_COUNT")
    dev_cmd_err_cnt = tlm("SAMPLE SAMPLE_HK_TLM DEVICE_ERR_COUNT")

    get_sample_data()
    # Note these checks assume default simulator configuration
    raw_x = tlm("SAMPLE SAMPLE_DATA_TLM RAW_SAMPLE_X")
    check("SAMPLE SAMPLE_DATA_TLM RAW_SAMPLE_Y >= #{raw_x*2}")
    check("SAMPLE SAMPLE_DATA_TLM RAW_SAMPLE_Z >= #{raw_x*3}")

    get_sample_hk()
    check("SAMPLE SAMPLE_HK_TLM DEVICE_COUNT >= #{dev_cmd_cnt}")
    check("SAMPLE SAMPLE_HK_TLM DEVICE_ERR_COUNT == #{dev_cmd_err_cnt}")
end

def confirm_sample_data_loop()
    SAMPLE_DEVICE_LOOP_COUNT.times do |n|
        confirm_sample_data()
    end
end

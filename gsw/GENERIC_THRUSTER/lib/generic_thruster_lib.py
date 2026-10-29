# Library for GENERIC_THRUSTER Target
import sys
import glob

for p in glob.glob('/gems/gems/openc3-cosmos-nos3-*/targets/GENERIC_THRUSTER/scripts'):
    if p not in sys.path:
        sys.path.append(p)

try:
    from openc3.script import cmd, tlm, check, wait_check_packet
    import time
except ImportError:
    pass

# 
# Definitions
# 
GENERIC_THRUSTER_CMD_SLEEP = 0.25
GENERIC_THRUSTER_RESPONSE_TIMEOUT = 5
GENERIC_THRUSTER_TEST_LOOP_COUNT = 1
GENERIC_THRUSTER_DEVICE_LOOP_COUNT = 1
GENERIC_THRUSTER_DEVICE_DELAY = 3
GENERIC_THRUSTER_DIFF = 0.5

#
# Functions
#
def get_generic_thruster_hk():
    cmd("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_REQ_HK")
    wait_check_packet("GENERIC_THRUSTER_DEBUG", "GENERIC_THRUSTER_HK_TLM", 1, GENERIC_THRUSTER_RESPONSE_TIMEOUT)
    time.sleep(GENERIC_THRUSTER_CMD_SLEEP)

def generic_thruster_cmd(command_string):
    count = tlm("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM CMD_COUNT") + 1

    if (count == 256):
        count = 0

    cmd(command_string)
    get_generic_thruster_hk()
    current = tlm("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM CMD_COUNT")
    if (current != count):
        # Try again
        cmd(command_string)
        get_generic_thruster_hk()
        cmd(command_string)
        get_generic_thruster_hk()
        current = tlm("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM CMD_COUNT")
        if (current != count):
            # Third time's the charm?
            cmd(command_string)
            get_generic_thruster_hk()
            current = tlm("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM CMD_COUNT")
            
    check(f"GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM CMD_COUNT >= {count}")

def enable_generic_thruster():
    # Send command
    generic_thruster_cmd("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_ENABLE_CC")
    # Confirm
    check("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM DEVICE_ENABLED == 'ENABLED'")    

def disable_generic_thruster():
    # Send command
    generic_thruster_cmd("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_DISABLE_CC")
    # Confirm
    check("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM DEVICE_ENABLED == 'DISABLED'")    

def safe_generic_thruster():
    get_generic_thruster_hk()
    state = tlm("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM DEVICE_ENABLED")
    if (state != "DISABLED"):
        generic_thruster_cmd("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_PERCENTAGE_CC with THRUSTER_NUMBER 0, PERCENTAGE 0")
        generic_thruster_cmd("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_PERCENTAGE_CC with THRUSTER_NUMBER 1, PERCENTAGE 0")
        generic_thruster_cmd("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_PERCENTAGE_CC with THRUSTER_NUMBER 2, PERCENTAGE 0")
        generic_thruster_cmd("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_PERCENTAGE_CC with THRUSTER_NUMBER 3, PERCENTAGE 0")
        disable_generic_thruster()

def confirm_generic_thruster_data():
    dev_cmd_cnt = tlm("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM DEVICE_COUNT")
    dev_cmd_err_cnt = tlm("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM DEVICE_ERR_COUNT")

    get_generic_thruster_hk()
    # Note these checks assume default simulator configuration

    truth_42_GYRO_X_initial = abs(tlm("SIM_42_TRUTH SIM_42_TRUTH_DATA WN_0"))
    truth_42_GYRO_Y_initial = abs(tlm("SIM_42_TRUTH SIM_42_TRUTH_DATA WN_1"))
    truth_42_GYRO_Z_initial = abs(tlm("SIM_42_TRUTH SIM_42_TRUTH_DATA WN_2"))

    generic_thruster_cmd("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_PERCENTAGE_CC with THRUSTER_NUMBER 0, PERCENTAGE 10")
    time.sleep(GENERIC_THRUSTER_DEVICE_DELAY)
    truth_42_GYRO_X_current = abs(tlm("SIM_42_TRUTH SIM_42_TRUTH_DATA WN_0")) + GENERIC_THRUSTER_DIFF
    truth_42_GYRO_Y_current = abs(tlm("SIM_42_TRUTH SIM_42_TRUTH_DATA WN_1")) + GENERIC_THRUSTER_DIFF
    truth_42_GYRO_Z_current = abs(tlm("SIM_42_TRUTH SIM_42_TRUTH_DATA WN_2")) + GENERIC_THRUSTER_DIFF
    generic_thruster_cmd("GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_PERCENTAGE_CC with THRUSTER_NUMBER 0, PERCENTAGE 0")

    if (truth_42_GYRO_X_current > truth_42_GYRO_X_initial) or (truth_42_GYRO_Y_current > truth_42_GYRO_Y_initial) or (truth_42_GYRO_Z_current > truth_42_GYRO_Z_initial):
        pass
    else:
        raise Exception("No difference in axis measurements: Test Failed!")

    check(f"GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM DEVICE_COUNT >= {dev_cmd_cnt}")
    check(f"GENERIC_THRUSTER_DEBUG GENERIC_THRUSTER_HK_TLM DEVICE_ERR_COUNT == {dev_cmd_err_cnt}")

def confirm_generic_thruster_data_loop():
    for n in range(GENERIC_THRUSTER_DEVICE_LOOP_COUNT):
        confirm_generic_thruster_data()

#
# Simulator Functions
#
def generic_thruster_prepare_ast():
    # Get to known state
    safe_generic_thruster()

    # Enable
    enable_generic_thruster()

    # Confirm data
    confirm_generic_thruster_data_loop()

def generic_thruster_sim_enable():
    cmd("SIM_CMDBUS_BRIDGE SAMPLE_SIM_ENABLE")

def generic_thruster_sim_disable():
    cmd("SIM_CMDBUS_BRIDGE SAMPLE_SIM_DISABLE")
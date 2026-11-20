local controller = peripheral.find("avionics_controller")

-- turn controller transponder off if not on
if !controller.isTransponderOn() then
    controller.setTransponder(on)
end
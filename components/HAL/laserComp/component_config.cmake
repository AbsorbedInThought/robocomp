set(laser_interfaces
     Laser
     DifferentialRobot
     )
     

set(laser_src
  laserComp/src/laserComp.cpp
  laserComp/src/laserI.cpp
  laserComp/src/gazebohandler.cpp
  laserComp/src/playerhandler.cpp
  laserComp/src/hokuyogenerichandler.cpp
  laserComp/src/hokuyohandler.cpp
  laserComp/src/sickhandler.cpp
  ${RoboComp_SOURCE_DIR}/classes/rapplication/rapplication.cpp
  ${RoboComp_SOURCE_DIR}/classes/q4serialport/q4serialport.cpp 
  )
  
set(laser_headers
  laserComp/src/laserI.h
  laserComp/src/generichandler.h
  laserComp/src/hokuyogenerichandler.h
  laserComp/src/hokuyohandler.h
  laserComp/src/sickhandler.h
  ${RoboComp_SOURCE_DIR}/classes/q4serialport/q4serialport.h
)

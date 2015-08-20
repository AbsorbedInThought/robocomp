#Using robocompdsl: the command line component generator

**robocompdsl** is the new tool used in RoboComp to automatically generate components and modify their main properties once they have been generated (e.g., communication requirements, UI type). It is one of the core tools of the framework so, if you installed RoboComp, you can start using it right away.

This new version can only be used from the command line, but the languages used to define components and their interfaces remain mostly the same: **CDSL** to specify components and **IDSL** to specify interfaces. The only difference with the old RoboCompDSLEditor tool is that the reserved keywords (are now case independent). Take a look to the tutorial ["a brief introduction to Components"](components.md) for an introduction to the concept of component generation and the languages involved.

There are three tasks we can acomplish using **robocompdsl**: 

* generating a CDSL template file
* generating the code for a previously existing CDSL file
* regenerating the code for an already generated component.

## Generating a CDSL template file
Even though writing CDSL files is easy --their structure is simple and the number of reserved words is very limited-- robocompdsl can generate template CDSL files to be used as a guide when writing CDSL files.

    $ robocompdsl path/to/mycomponent/mycomponent.cdsl

This will generate a CDSL file with the following content:

    import "/robocomp/interfaces/IDSLs/import1.idsl";
    import "/robocomp/interfaces/IDSLs/import2.idsl";
    Component CHANGETHECOMPONENTNAME
    {
    	Communications
    	{
    		implements interfaceName;
    		requires otherName;
    		subscribesTo topicToSubscribeTo;
    		publishes topicToPublish;
    	};
    	language Cpp;
    	gui Qt(QWidget);
    };

The CDSL language is described in the tutorial ["A brief introduction to Components"](components.md). Just don't forget to change the name of the component.

 
## Generating a component given a CDSL file
 
Let's change the template file above by something like this, 

    import "/robocomp/interfaces/IDSLs/DifferentialRobot.idsl";
    import "/robocomp/interfaces/IDSLs/Laser.idsl";
    Component MyFirstComp{
        Communications{
            requires DifferentialRobot, Laser;
        };
    language Cpp; //language Python;
    };
    
and save it as *mycomponent.cdsl*. Now run again robocompdsl with the CDSL file as first argument and the directory where the code should be placed as the second argument.

From the component's directory:
    
    cd path/to/mycomponent
    robocompdsl mycomponent.cdsl .

Watch the dot at the end!
Or somewhere else:

    robocompdsl path/to/mycomponent/mycomponent.cdsl path/to/mycomponent

These commands will generate the C++ (or Python) code in the specified directory.

## Modfiying the component to write a simple controller for the robot
Check that the *rcis* simulator is up and running. You should have two open windows, one with a camara looking at the world and another with the subjective camera of the robot. In not, in a new terminal type,

    cd ~/robocomp/files/innermodel
    rcis simpleworld.xml
    
Now, goto to the src subdirectory of the new component, 

    cd path/to/mycomponent/src
    
and open *specificworker.cpp* in your favorite editor. Go to the **void SpecificWorker::compute()** method and replace it with,
```
void SpecificWorker::compute( )
{

    const float threshold = 200;
    float rot = 1.5707;	
	
    

    try
    {
        RoboCompLaser::TLaserData ldata = laser_proxy->getLaserData();
        std::sort( ldata.begin(), ldata.end(), [](RoboCompLaser::TData a, RoboCompLaser::TData b){ return     a.dist < b.dist; }) ;
        
	
	 if( ldata.front().dist < threshold)
	{
 	differentialrobot_proxy->setSpeedBase(5, rot);
	usleep(1250000);
	std::cout << ldata.front().dist << std::endl;	
	differentialrobot_proxy->setSpeedBase(200, 0);
	usleep(500000);
	rot = rot + 0.12;
	if( rot > 3 * 1.5707 )
	{
	 rot = 1.5707;
	}
	}
	
	else
	{
	differentialrobot_proxy->setSpeedBase(200, 0); 
  	usleep(500000);
	std::cout << ldata.front().dist << std::endl;
  	}

       	
    }
    catch(const Ice::Exception &ex)
    {
        std::cout << ex << std::endl;
    }

}
```
save and, 

    cd ..
    make
    
Note that we are using a lambda function as a parameter to the std::sort function so you will need a gcc compiler version equal or newer than 4.9. Check with gcc -v. If you don't have it, substitute the sort method with your own sorting procedure.

If you have generated the code using python the replace the *specificworker.py* found in the src folder with this code

		def compute(self):
			print 'SpecificWorker.compute...'
			rot = 0.7
			try:
				ldata = []
				d = []
				ldata = self.laser_proxy.getLaserData();
				for i in range(0,len(ldata)):
					dis = ldata[i]
					y = dis.dist
					d.append(y)
				d.sort()
				distance = d[0]
				print distance
				if distance < 400:
					self.differentialrobot_proxy.setSpeedBase(0, rot)
					time.sleep(1)
					rot = rot+ 0.5
					if rot > 3:
						rot = 1
					self.differentialrobot_proxy.setSpeedBase(70, 0)
					time.sleep(1)
				else:
					self.differentialrobot_proxy.setSpeedBase(100, 0)
					time.sleep(1)
			except Ice.Exception, e:
				traceback.print_exc()
				print e
			return True

Save the file.

Now we need to tell the component where to find the DifferentialRobot and the Laser interfaces. Of course they are implemented by the rcis simulator so we only need to change the ports in the configuration file,

     cd path/to/mycomponent/etc
     gedit config
     
Change in the editor the port numbers located after *-p* 
     
    CommonBehavior.Endpoints=tcp -p 11000
    # Proxies for required interfaces
    LaserProxy = laser:tcp -h localhost -p 10003
    DifferentialRobotProxy = differentialrobot:tcp -h localhost -p 10004
    Ice.Warn.Connections=0
    Ice.Trace.Network=0
    Ice.Trace.Protocol=0
    Ice.ACM.Client=10
    Ice.ACM.Server=10

Save and 

    cd ..

Now start the component,

For c++,

    bin/mycomponent --Ice.Config=etc/config

For Python,

    python bin/mycomponent --Ice.Config=etc/config

and watch the robot avoiding obstacles! Change the code to improve the behavior of the robot.

## Updating the source code of a component after modifying its CDSL file
Once we generated our component we might change our mind and decide to add a new connection to another interface or to publish a new topic. In these cases we can regenerate the code of the component just by changing the *.cdsl* file and executing again the command.

As you might have learned from the tutorial ["A brief introduction to Components"](components.md) RoboComp components are divided in specific code (files where you write your code) and generic code (autogenerated code which doesn't need to be edited). Running robocompdsl again on the same directory will ony overwrite these generic files. To ensure robocompdsl doesn't overwrite the changes you made to the specific files these are left unchanged, so the component might not compile after regeneration (e.g., you might need to add new methods).






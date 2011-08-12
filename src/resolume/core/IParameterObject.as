package resolume.core {
	
	import flash.events.*;
	
	import resolume.parameter.*;
	
	public interface IParameterObject extends IEventDispatcher {
		
		function getParameters():ParameterList;
		// function bind(callback:Function, ... events:Array):void;
		// function unbind(callback:Function, ... events:Array):void;
		
		function attach(parameters:Vector.<Parameter>):void;
		
		function getParameterValue(name:String):*;
		function setParameterValue(name:String, value:*):void;
		
	}
}
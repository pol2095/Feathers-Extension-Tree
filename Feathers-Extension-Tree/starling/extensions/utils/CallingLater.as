/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package starling.extensions.utils 
{
	import starling.events.EnterFrameEvent;
	import starling.core.Starling;
	import flash.events.Event;
	
	public class CallingLater
	{
		protected static var _calledLater:Vector.<CallLaterData> = new Vector.<CallLaterData>();
		protected static var _calledLaterNum:Vector.<uint> = new Vector.<uint>();
		protected static var toggleFrame:Boolean;
		
		public static function call(func:Function, args:Array = null):void
		{
			_calledLater.unshift(new CallLaterData(func, args, Starling.current.stage));
			_calledLaterNum.unshift(toggleFrame);
			if (_calledLater.length == 1)
			{
				Starling.current.stage.addEventListener(EnterFrameEvent.ENTER_FRAME, callLaterEnterFrameHandler);
				Starling.current.nativeStage.addEventListener(Event.EXIT_FRAME, callLaterExitFrameHandler);
			}
		}
		protected static function callLaterExitFrameHandler(event:Event):void
		{
			toggleFrame = !toggleFrame;
		}
		protected static function callLaterEnterFrameHandler(event:EnterFrameEvent):void
		{
			var data:CallLaterData;
			for(var i:int = _calledLaterNum.length-1; i >= 0; i--)
			{
				if(_calledLaterNum[i] != toggleFrame)
				{
					_calledLaterNum.pop();
					data = _calledLater.pop() as CallLaterData;
					data.call();
				}
			}
			
			if (_calledLater.length == 0)
			{
				event.target.removeEventListener(EnterFrameEvent.ENTER_FRAME, callLaterEnterFrameHandler);
				Starling.current.nativeStage.removeEventListener(Event.EXIT_FRAME, callLaterExitFrameHandler);
			}
		}
	}
}
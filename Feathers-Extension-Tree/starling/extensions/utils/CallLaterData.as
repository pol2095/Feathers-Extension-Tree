/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package starling.extensions.utils
{
	public class CallLaterData 
	{
		protected var _this:Object;
		protected var _args:Array;
		protected var _func:Function;
		
		public function CallLaterData(func:Function, args:Array, $this:Object) 
		{
			_this = $this;
			_args = args;
			_func = func;
		}
		
		public function call():void
		{
			_func.apply(_this, _args);
		}
	}
}
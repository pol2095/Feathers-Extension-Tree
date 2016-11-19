/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package starling.extensions.utils
{
	/**
	 * The callLater() method queues an operation to be performed for the next screen refresh, rather than in the current update. Without the callLater() method, you might try to access a property of a component that is not yet available.
	 */
	public function callLater(func:Function, args:Array = null):void
	{
		CallingLater.call( func, args );
	}
}
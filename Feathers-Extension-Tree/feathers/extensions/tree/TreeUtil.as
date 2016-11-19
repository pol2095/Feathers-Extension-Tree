/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.tree
{
    import feathers.controls.LayoutGroup;
	import starling.display.DisplayObjectContainer;
	import starling.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TreeUtil
    {		
		public static function createItemRenderer(myObject:Object, _this:Object, layoutGroup:LayoutGroup):void
		{
			if(myObject.hasOwnProperty("children")) myObject = myObject.children;
			for (var s:String in myObject)
			{
				loopItemRenderer(myObject[s], _this, layoutGroup);
			}
		}
		private static function loopItemRenderer(value:Object, _this:Object, layoutGroup:LayoutGroup):void
		{
			if(typeof(value) == "object") 
			{
				if(value is Object)
				{
					if(value.hasOwnProperty("children"))
					{
						_this.addLayout(value, layoutGroup); 
					}
					else
					{
						_this.addItemRenderer(value, layoutGroup);
					}
				}
			}
		}
		
		public static function move(json:Object, dropping:Object, dragging:Object, isBefore:Boolean):void
		{
			endLoopInsert = false;
			var draggingObject:Object = dragging.object;
			var droppingObject:Object = dropping.object;
			if(dropping.isDirectory) dropping = dropping.parent;
			if(dragging.isDirectory) dragging = dragging.parent;
			var position:int = dropping.parent.getChildIndex(dropping);
			if(dropping.parent === dragging.parent)
			{
				if(position < dragging.parent.getChildIndex(dragging)) position += 1;
				if(isBefore) position -= 1;
				dropping.parent.setChildIndex(dragging, position);
				loopObjectDelete(json, draggingObject);
				loopObjectInsert(json, droppingObject, position, draggingObject); //loopObjectReplace(json, droppingObject, position);
			}
			else
			{
				if(!isBefore) position += 1;
				var ItemRendererParent:DisplayObject = dragging.parent.parent.getChildAt(0);
				dragging.parent.removeChild(dragging);
				dropping.parent.addChildAt(dragging, position);
				loopObjectDelete(json, draggingObject);
				loopObjectInsert(json, droppingObject, position, draggingObject);
			}
		}
		
		public static function moveNext(json:Object, dropping:Object, dragging:Object):void
		{
			var draggingObject:Object = dragging.object;
			var droppingObject:Object = dropping.object;
			if(dragging.isDirectory) dragging = dragging.parent;
			var ItemRendererParent:DisplayObject = dragging.parent.parent.getChildAt(0);
			dragging.parent.removeChild(dragging);
			if(dropping.isOpen) dropping.layoutGroup.addChild(dragging);
			loopObjectDelete(json, draggingObject);
			droppingObject.children.push( draggingObject );
		}
		
		public static function loopObjectDelete(myObject:Object, target:Object):void
		{
			for (var s:String in myObject) loopDelete(myObject, s, target);
		}
		private static function loopDelete(myObject:Object, s:String, target:Object):void
		{
			if(typeof(myObject[s]) == "object") 
			{
				loopObjectDelete(myObject[s], target);
				if(myObject[s] === target) myObject.splice(s, 1); //tempObject = 
			}
		}
		
		private static var outSeparator:Boolean;
		public static function createSeparator(_this:Object, mouse:Point):void
		{
			outSeparator = false;
			loopObjectSeparator(_this.tree, _this, mouse);
			if(!outSeparator) _this.removeSeparator();
		}
		private static function loopObjectSeparator(myObject:Object, _this:Object, mouse:Point):void
		{
			for (var i:int; i < myObject.numChildren; i++) loopSeparator(myObject.getChildAt(i), _this, mouse);
		}
		private static function loopSeparator(myObject:Object, _this:Object, mouse:Point):void
		{
			if(!myObject.hasOwnProperty("object"))
			{
				loopObjectSeparator(myObject, _this, mouse);
			}
			else
			{
				var pt:Point = myObject.localToGlobal(new Point (0, 0));
				var rect:Rectangle = new Rectangle(pt.x, pt.y, myObject.width, myObject.height);
				if(rect.containsPoint(mouse))
				{
					_this.onSeparator(myObject, _this.tree.globalToLocal(pt));
					outSeparator = true;
				}
			}
		}
		
		public static function isSelf(tree:LayoutGroup, myObject:Object, target:Object):Boolean
		{
			var firstChild:Object;
			if(!myObject) return true;
			while(myObject != tree)
			{
				if(myObject === target) return true;
				myObject = myObject.parent;
				if(myObject is LayoutGroup)
				{
					firstChild = myObject.parent.getChildAt(0);
					if(firstChild.hasOwnProperty("object"))
					{
						if(firstChild.isDirectory) myObject = firstChild;
					}
				}
			}
			return false;
		}
		
		public static function insertIn(buttonMenuHover:Object, newButton:DisplayObjectContainer, object:Object):void
		{
			if(buttonMenuHover.isOpen) buttonMenuHover.layoutGroup.addChild(newButton);
			buttonMenuHover.object.children.push( object );
		}
		
		public static function insert(json:Object, buttonMenuHover:Object, newButton:DisplayObjectContainer, object:Object, isBefore:Boolean):void
		{
			endLoopInsert = false;
			var buttonMenuHoverObject:Object = buttonMenuHover.object;
			if(buttonMenuHover.isDirectory) buttonMenuHover = buttonMenuHover.parent;
			var position:int = buttonMenuHover.parent.getChildIndex(buttonMenuHover);
			if(!isBefore) position += 1;
			buttonMenuHover.parent.addChildAt(newButton, position);
			loopObjectInsert(json, buttonMenuHoverObject, position, object);
		}
		private static var endLoopInsert:Boolean;
		private static function loopObjectInsert(myObject:Object, target:Object, position:int, object:Object):void
		{
			for (var s:String in myObject)
			{
				if(endLoopInsert) break;
				loopInsert(myObject, s, target, position, object);
			}
		}
		private static function loopInsert(myObject:Object, s:String, target:Object, position:int, object:Object):void
		{
			if(typeof(myObject[s]) == "object") 
			{
				if(myObject[s] === target)
				{
					myObject.splice(position, 0, object);
					endLoopInsert = true;
				}
				loopObjectInsert(myObject[s], target, position, object);
			}
		}
    }
}
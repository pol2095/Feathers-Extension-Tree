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
	
	/**
	 *  The TreeUtil class is an all-static class with methods for working with Tree control.
	 *
	 * @see http://pol2095.free.fr/Feathers-Extension-Tree/ How to use Tree with mxml
	 */
	public class TreeUtil
    {		
		/**
		 * @private
		 */
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
		
		/**
		 * @private
		 */
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
				loopObjectInsert(json, droppingObject, position, draggingObject);
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
		
		/**
		 * @private
		 */
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
		
		/**
		 * @private
		 */
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
		/**
		 * @private
		 */
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
		
		/**
		 * @private
		 */
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
		
		/**
		 * @private
		 */
		public static function insertIn(buttonMenuHover:Object, newButton:DisplayObjectContainer, object:Object):void
		{
			if(buttonMenuHover.isOpen) buttonMenuHover.layoutGroup.addChild(newButton);
			buttonMenuHover.object.children.push( object );
		}
		
		/**
		 * @private
		 */
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
		
		private static var numChildren:int;
		/**
		 * @private
		 */
		public static function numSubChildren(item:Object):int
		{
			numChildren = 0;
			numSubChildrenLoop(item);
			return numChildren;
		}
		private static function numSubChildrenLoop(item:Object):void
		{
			for(var i:int = 0; i < item.numChildren; i++)
			{
				if( item.getChildAt(i).hasOwnProperty("object") )
				{
					numChildren++;
				}
				else
				{
					numSubChildrenLoop( item.getChildAt(i) );
				}
			}
		}
		
		/**
		 * Convert a JSON (dataProvider Tree format) in a XML Object (Tree format).
		 *
		 * @param json a JSON Object
		 */
		public static function jsonToXml(json:Object):XML
		{
			var xml:XML = <tree/>;
			jsonToXmlObjectLoop(json, xml);
			return xml;
		}
		private static function jsonToXmlObjectLoop(json:Object, xml:Object):void
		{
			for (var s:String in json)
			{
				jsonToXmlLoop(json[s], xml);
			}
		}
		private static function jsonToXmlLoop(json:Object, xml:Object):void
		{
			if(typeof(json) == "object") 
			{
				if(json is Object)
				{
					var node:XML = json.hasOwnProperty("children") ? <branch/> : <leaf/>;
					xml.appendChild( node );
					for (var s:String in json)
					{
						if(s != "children")
						{
							node.@[s] = json[s];
						}
						else
						{
							jsonToXmlObjectLoop(json.children, xml.children()[ xml.children().length() - 1 ]); // last child
						}
					}
				}
			}
		}
		/**
		 * Convert a XML Object (Tree format) in a JSON (dataProvider Tree format).
		 *
		 * @param xml a XML Object
		 */
		public static function xmlToJson(xml:XML):Object
		{
			var json:Object = [];
			xmlToJsonObjectLoop(xml, json);
			return json;
		}
		private static function xmlToJsonObjectLoop(xml:Object, json:Object):void
		{
			for each(var node:Object in xml.children())
			{
				xmlToJsonLoop(node, json);
			}
		}
		private static function xmlToJsonLoop(xml:Object, json:Object):void
		{
			var object:Object = {};
			json.push( object );
			var attributes:XMLList = xml.attributes();
			for each(var attribute:Object in attributes)
			{
				object[attribute.name().toString()] = attribute.valueOf().toString();
			}
			if( xml.children().length() > 0 )
			{
				object.children = [];
				xmlToJsonObjectLoop(xml, object.children);
			}
		}
    }
}
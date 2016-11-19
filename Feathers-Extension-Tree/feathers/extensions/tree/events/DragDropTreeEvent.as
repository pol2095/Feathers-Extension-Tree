/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.tree.events {
	import starling.events.Event;
	
	/**
	 * A event dispatched when a item is dragged and dropped.
	 *
	 * @see http://pol2095.free.fr/Feathers-Extension-Tree/ How to use Tree with mxml
	 * @see feathers.extensions.tree.Tree
	 */
	public class DragDropTreeEvent extends Event {
		
		/**
		 * Dispatched when a tree item is dragged and dropped.
		 */
		public static var DRAG_COMPLETE:String = "dragComplete";
		
		private var _newIndex:Vector.<int>;
		private var _lastIndex:Vector.<int>;
		private var _isDirectory:Boolean;

		public function DragDropTreeEvent(type:String, newIndex:Vector.<int>, lastIndex:Vector.<int>, isDirectory:Boolean, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			_newIndex = newIndex;
			_lastIndex = lastIndex;
			_isDirectory = isDirectory;
		}
		
		/**
		 * The new index of the dragged and dropped tree item.
		 */
		public function get newIndex():Vector.<int> { return _newIndex; }
		/**
		 * The last index of the dragged and dropped tree item.
		 */
		public function get lastIndex():Vector.<int> { return _lastIndex; }
		/**
		 * Indicates whether the item is a branch.
		 */
		public function get isDirectory():Boolean { return _isDirectory; }
	}
}
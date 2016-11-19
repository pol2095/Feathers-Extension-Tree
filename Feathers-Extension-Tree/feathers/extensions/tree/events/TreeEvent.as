/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.tree.events {
	import starling.events.Event;
	
	/**
	 * A event dispatched when a tree row changes
	 *
	 * @see http://pol2095.free.fr/Feathers-Extension-Tree/ How to use Tree with mxml
	 * @see feathers.extensions.tree.Tree
	 */
	public class TreeEvent extends Event {
		
		/**
		 * Dispatched when a tree item changes.
		 */
		public static var CHANGE:String = "change";
		
		/**
		 * Dispatched when a tree item selected.
		 */
		public static var SELECT:String = "select";
		
		private var _index:Vector.<int>;
		private var _isDirectory:Boolean;
		private var _data:Object;
		private var _item:Object;

		public function TreeEvent(type:String, index:Vector.<int>, isDirectory:Boolean, data:Object, item:Object, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			_index = index;
			_isDirectory = isDirectory;
			_data = data;
			_item = item;
		}
		
		/**
		 * The index of tree item.
		 *
		 * @default 10
		 */
		public function get index():Vector.<int> { return _index; }
		/**
		 * Indicates whether the item is a branch.
		 */
		public function get isDirectory():Boolean { return _isDirectory; }
		/**
		 * The tree dataProvider item corresponding to this item renderer.
		 */
		override public function get data():Object { return _data; }
		/**
		 * The item renderer.
		 */
		public function get item():Object { return _item; }
	}
}
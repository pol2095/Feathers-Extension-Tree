/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.tree
{
	import starling.events.EnterFrameEvent;
	import feathers.layout.HorizontalLayout;
	
	import feathers.dragDrop.IDragSource;
	import feathers.dragDrop.IDropTarget;
	
	import starling.display.Quad;
	import flash.geom.Rectangle;
	import starling.display.Quad;
	import feathers.controls.LayoutGroup;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
 
    /**
	 * The row of a tree control.
	 *
	 * @see http://pol2095.free.fr/Feathers-Extension-Tree/ How to use Tree with mxml
	 * @see feathers.extensions.tree.Tree
	 */
	public class TreeItemRenderer extends LayoutGroup implements IDragSource, IDropTarget
    {		
		private var lineRightHover:Quad;
		private var lineLeftHover:Quad;
		private var lineTopHover:Quad;
		private var lineBottomHover:Quad;
		private var lineRightSelected:Quad;
		private var lineLeftSelected:Quad;
		private var lineTopSelected:Quad;
		private var lineBottomSelected:Quad;
		
		private function get hoverLineColor():uint
		{
			return owner.hoverLineColor;
		}
		private function get selectLineColor():uint
		{
			return owner.selectLineColor;
		}
		private function get lineSize():Number
		{
			return owner.lineSize;
		}
		
		/**
		 * @private
		 */
		public var layoutGroup:LayoutGroup;
		/**
		 * @private
		 */
		public var layoutGroupButton:Object;
		/**
		 * @private
		 */
		public var object:Object;
		/**
		 * Indicates whether the item is open.
		 */
		public var isOpen:Boolean;
		/**
		 * @private
		 */
		public var quad:Quad;
		
		/**
		 * The index position in the tree.
		 */
        public function get index():Vector.<int>
		{
			return owner.getItemIndex( this );
		}
		/**
		 * Indicates whether the item is selected.
		 */
		public var isSelected:Boolean;
		/**
		 * Indicates whether the tree dataProvider item corresponding to this item renderer is being changing.
		 */
		protected var isChanging:Boolean;
		
		private var countEnterFrame:int;
		
		/**
		 * The tree dataProvider item corresponding to this item renderer.
		 */
		public function get data():Object
		{
			return this.object;
		}
		
		private var _isDirectory:Boolean;
		/**
		 * Indicates whether the item is a branch.
		 */
		public function get isDirectory():Boolean
		{
			return _isDirectory;
		}
		public function set isDirectory(value:Boolean):void
		{
			_isDirectory = value;
			if(owner.hoverSelector) this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private var _owner:Tree;
		/**
		 * The tree control that contains this item renderer.
		 */
		public function get owner():Tree
		{
			return _owner;
		}
		public function set owner(value:Tree):void
		{
			_owner = value;
			var layout:HorizontalLayout = this.layout as HorizontalLayout;
			layout.paddingLeft = layout.paddingRight = layout.paddingTop = layout.paddingBottom = lineSize;
			
			var layoutGroup:LayoutGroup = new LayoutGroup();
			layoutGroup.includeInLayout = false;
			lineLeftHover = new Quad(lineSize, lineSize);
			layoutGroup.addChild( lineLeftHover );
			lineRightHover = new Quad(lineSize, lineSize);
			layoutGroup.addChild( lineRightHover );
			lineTopHover = new Quad(lineSize, lineSize);
			layoutGroup.addChild( lineTopHover );
			lineBottomHover = new Quad(lineSize, lineSize);
			layoutGroup.addChild( lineBottomHover );
			
			lineLeftSelected = new Quad(lineSize, lineSize);
			layoutGroup.addChild( lineLeftSelected );
			lineRightSelected = new Quad(lineSize, lineSize);
			layoutGroup.addChild( lineRightSelected );
			lineTopSelected = new Quad(lineSize, lineSize);
			layoutGroup.addChild( lineTopSelected );
			lineBottomSelected = new Quad(lineSize, lineSize);
			layoutGroup.addChild( lineBottomSelected );
			
			lineRightHover.y = lineLeftHover.y = lineRightSelected.y = lineLeftSelected.y = lineSize;
			lineRightHover.alpha = lineLeftHover.alpha = lineTopHover.alpha = lineBottomHover.alpha = lineRightSelected.alpha = lineLeftSelected.alpha = lineTopSelected.alpha = lineBottomSelected.alpha = 0;
			this.addChild( layoutGroup );
		}
		
		private var backGround:Quad;
		
		public function TreeItemRenderer()
        {
			super();
			var layoutGroup:LayoutGroup = new LayoutGroup();
			layoutGroup.includeInLayout = false;
			backGround = new Quad(1, 1);
			backGround.alpha = 0;
			layoutGroup.addChild( backGround );
			this.addChild( layoutGroup );
        }
		/**
		 * @private
		 */
		override protected function draw():void
        {
			super.draw();
			
			backGround.width = this.width;
			backGround.height = this.height;
			
			lineRightHover.x = lineRightSelected.x = this.width - lineSize;
			lineBottomHover.y = lineBottomSelected.y = this.height - lineSize;
			lineTopHover.width = lineBottomHover.width = lineTopSelected.width = lineBottomSelected.width = this.width;
			lineLeftHover.height = lineRightHover.height = lineLeftSelected.height = lineRightSelected.height = this.height - lineSize;
        }
		
		/**
		 * Dispatched after the tree dataProvider item corresponding to this item renderer has changed.
		 *
		 * <listing version="3.0">
		 * override public function treeChangeHandler():void
		 * {
		 *   super.treeChangeHandler(); //never forget to add this!
		 *   
		 *   yourControl = this.data.key; //your code here
		 * }</listing>
		 */
		public function treeChangeHandler():void
        {
			isChanging = true;
			if(countEnterFrame == 0)
			{
				this.addEventListener(EnterFrameEvent.ENTER_FRAME, onDataGridChangeHandler);
				countEnterFrame++;
			}
		}
		/**
		 * Allows to change the item tree dataProvider corresponding to this item renderer and dispatch a <code>TreeEvent.CHANGE</code> on the tree corresponding to this item renderer.
		 *
		 * <listing version="3.0">
		 * override protected function rowChangeHandler():void
		 * {
		 *   if(isChanging) return; //never forget to add this!
		 *   
		 *   this.data.key = yourControl; //your code here
		 * 
		 *   super.rowChangeHandler(); //never forget to add this!
		 * }</listing>
		 *
		 * @see feathers.extensions.tree.events.TreeEvent
		 */
		protected function rowChangeHandler():void
        {
			owner.rowChange(index, this.isDirectory, this.object, this);
		}
		private function onDataGridChangeHandler(event:EnterFrameEvent):void
        {
			isChanging = false;
			this.removeEventListener(EnterFrameEvent.ENTER_FRAME, onDataGridChangeHandler);
			countEnterFrame--;
		}
		/**
		 * @private
		 */
		public function selectedLines():void
		{
			if(isSelected)
			{
				lineLeftSelected.alpha = lineRightSelected.alpha = lineTopSelected.alpha = lineBottomSelected.alpha = 0;
			}
			else
			{
				var color:uint = selectLineColor;
				lineLeftSelected.color = lineRightSelected.color = lineTopSelected.color = lineBottomSelected.color = color
				lineLeftSelected.alpha = lineRightSelected.alpha = lineTopSelected.alpha = lineBottomSelected.alpha = 1;
			}
		}
		private function onTouch(touch:TouchEvent):void
		{
			if (touch.getTouch(this, TouchPhase.HOVER))
			{
				var color:uint = hoverLineColor;
				lineLeftHover.color = lineRightHover.color = lineTopHover.color = lineBottomHover.color = color;
				lineLeftHover.alpha = lineRightHover.alpha = lineTopHover.alpha = lineBottomHover.alpha = 0.5;
			}
			else
			{
				lineLeftHover.alpha = lineRightHover.alpha = lineTopHover.alpha = lineBottomHover.alpha = 0;
			}
		}
	}
}
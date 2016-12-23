/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.tree
{
	import feathers.controls.ScrollContainer;
	import feathers.dragDrop.DragData;
	import feathers.dragDrop.DragDropManager;
	import feathers.events.DragDropEvent;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.events.EnterFrameEvent;
	import starling.display.DisplayObject;
	import starling.display.Stage;
	import starling.textures.Texture;
	import flash.display.BitmapData;
	import starling.rendering.Painter;
	import starling.core.Starling;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import feathers.controls.LayoutGroup;
	import feathers.layout.VerticalLayout;
	import starling.display.Quad;
	import feathers.extensions.tree.events.TreeEvent;
	import feathers.extensions.tree.events.DragDropTreeEvent;
	import flash.utils.getDefinitionByName;
	import starling.display.DisplayObjectContainer;
	import feathers.dragDrop.IDragSource;
	import feathers.dragDrop.IDropTarget;
	import flash.utils.setTimeout;
	import starling.extensions.utils.callLater;
	
	/**
	 * Dispatched when a tree item changes.
	 */
	[Event(name="change", type="feathers.extensions.tree.events.TreeEvent")]
	/**
	 * Dispatched when a tree item is selected.
	 */
	[Event(name="select", type="feathers.extensions.tree.events.TreeEvent")]
	/**
	 * Dispatched when a tree item is dragged and dropped.
	 */
	[Event(name="dragComplete", type="feathers.extensions.tree.events.DragDropTreeEvent")]
	
	/**
	 *  The Tree control lets a user view hierarchical data arranged as an expandable tree.
	 *  Each item in a tree can be a leaf or a branch.
	 *  A leaf item is an end point in the tree.
	 *  A branch item can contain leaf or branch items, or it can be empty.
	 *
	 * @see http://pol2095.free.fr/Feathers-Extension-Tree/ How to use Tree with mxml
	 * @see feathers.extensions.tree.TreeItemRenderer
	 */
	public class Tree extends ScrollContainer
	{
		private var _lineSize:Number = 2;
		/**
		 * the size of the tree item renderer lines in pixels.
		 *
		 * @default 2
		 */
		public function get lineSize():Number
		{
			return this._lineSize;
		}
		public function set lineSize(value:Number):void
		{
			this._lineSize = value;
		}
		
		private var _hoverLineColor:uint = 0xFFA500;
		/**
		 * The default color of lines when the mouse is hover.
		 *
		 * @default 0xCCCCCC
		 */
		public function get hoverLineColor():uint
		{
			return this._hoverLineColor;
		}
		public function set hoverLineColor(value:uint):void
		{
			this._hoverLineColor = value;
		}
		
		private var _selectable:Boolean = false;
		/**
		 * Determines if terminal items in the tree may be selected.
		 *
		 * @default false
		 */
		public function get selectable():Boolean
		{
			return this._selectable;
		}
		public function set selectable(value:Boolean):void
		{
			this._selectable = value;
		}
		
		private var _hoverSelector:Boolean = false;
		/**
		 * Determines if the item highlighting when the mouse is hover.
		 *
		 * @default false
		 */
		public function get hoverSelector():Boolean
		{
			return this._hoverSelector;
		}
		public function set hoverSelector(value:Boolean):void
		{
			this._hoverSelector = value;
		}
		
		private var _draggable:Boolean = false;
		/**
		 * Determines if items in the tree may be draggable.
		 *
		 * @default false
		 */
		public function get draggable():Boolean
		{
			return this._draggable;
		}
		public function set draggable(value:Boolean):void
		{
			this._draggable = value;
		}
		
		private var _selectLineColor:uint = 0xFFA500;
		/**
		 * The color of lines when a row is selected.
		 *
		 * @default 0xCCCCCC
		 */
		public function get selectLineColor():uint
		{
			return this._selectLineColor;
		}
		public function set selectLineColor(value:uint):void
		{
			this._selectLineColor = value;
		}
		
		private var _indent:int = 10;
		/**
		 * The indentation of tree item.
		 *
		 * @default 10
		 */
		public function get indent():uint
		{
			return this._indent;
		}
		public function set indent(value:uint):void
		{
			this._indent = value;
		}
		
		private var ItemRenderer:Class;
		/**
		 * The class used to instantiate item renderers.
		 */
		public function set itemRenderer(value:Object):void
		{
			if( !(value is Class) ) value = getDefinitionByName(value as String);
			ItemRenderer = value as Class;
		}
		
		private var touch:Touch;
		private var dragging:Object;
		private var dropping:Object;
		private var mouse:Point;
		private var draggingIndex:Vector.<int>;
		/**
		 * @private 
		 */
		public var tree:LayoutGroup;
		
		public function Tree()
		{
			tree = new LayoutGroup();
			tree.layout = new VerticalLayout();
			(tree.layout as VerticalLayout).paddingTop = (tree.layout as VerticalLayout).paddingBottom = separator / 2;
			this.addChild( tree );
			tree.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		private var _dataProvider:Object;
		/**
		 * The json displayed by the tree. Changing this property
		 * to a new value is considered a drastic change to the tree's data, so
		 * the horizontal and vertical scroll positions will be reset, and the
		 * tree's selection will be cleared.
		 *
		 * JSON structure :
		 * <listing version="3.0">
		 * var json:Object = [
		 * 	{
		 * 		"name": "File 1",
		 * 		"url": "http://www.file1.com/"
		 * 	},
		 * 	{
		 * 		"name": "Folder 1",
		 * 		"children": [
		 * 			{
		 * 				"name": "File 2",
		 * 				"url": "http://www.file2.com/"
		 * 			},
		 * 			{
		 * 				"name": "Folder 2",
		 * 				"children": [
		 * 					{
		 * 						"name": "File 3",
		 * 						"url": "http://www.file3.com/"
		 * 					}
		 * 				]
		 * 			}
		 * 		]
		 * 	},
		 * 	{
		 * 		"name": "File 4",
		 * 		"url": "http://www.file4.com/"
		 * 	}
		 * ];</listing>
		 */
		public function get dataProvider():Object
		{
			return _dataProvider;
		}
		public function set dataProvider(value:Object):void
		{
			_dataProvider = value;
			if(_dataProvider)
			{
				tree.removeChildren();
				TreeUtil.createItemRenderer(_dataProvider, this, tree);
			}
		}
		
		private function onStartDrag(dragging:Object):void
		{
			this.dragging = dragging;
			draggingIndex = this.getItemIndex(dragging);
			var avatar:Image = new Image( Texture.fromBitmapData( takeScreenshot(stage.starling, dragging as DisplayObjectContainer) ) );
			avatar.alpha = 0.5;
			
			var dragData:DragData = new DragData();
			dragData.setDataForFormat("tree-extension-drag-format", avatar);
			DragDropManager.startDrag(dragging as IDragSource, touch, dragData, avatar, -avatar.width / 2, -avatar.height / 2);
			
			stage.addEventListener(EnterFrameEvent.ENTER_FRAME, EnterFrameDragHandler);
		}
		private function dragEnterHandler(event:DragDropEvent, dragData:DragData):void
		{
			if(dragData.hasDataForFormat("tree-extension-drag-format"))
			{
				DragDropManager.acceptDrag(event.currentTarget as IDropTarget);
			}
		}
		private function touchHandler(event:TouchEvent):void
		{
			var touchBegan:Touch = event.getTouch(stage, TouchPhase.BEGAN);
			var _selectIndex:Object;
			var target:Object;
			if(touchBegan)
			{
				touch = touchBegan;
				mouse = touchBegan.getLocation(stage);
				
				target = touch.target as Object;
				_selectIndex = selectTouchIndex(target);
				if(draggable) setTimeout(longPressHandler, 600, _selectIndex);
			}
			var touchMoved:Touch = event.getTouch(stage, TouchPhase.MOVED);
			if(touchMoved)
			{
				touch = touchMoved;
				mouse = touchMoved.getLocation(stage);
				if(DragDropManager.isDragging) TreeUtil.createSeparator(this, mouse);
			}
			var touchEnded:Touch = event.getTouch(stage, TouchPhase.ENDED);
			if (touchEnded)
			{
				touch = touchEnded;
				
				if(DragDropManager.isDragging)
				{
					stage.removeEventListener(EnterFrameEvent.ENTER_FRAME, EnterFrameDragHandler);
					removeSeparator();
				}
				else
				{
					target = touch.target as Object;
					if(target == this) return;
					_selectIndex = selectTouchIndex(target);
					onClickBD(_selectIndex);
				}
			}
		}
		private function longPressHandler(_selectIndex:Object):void {
			if(touch.phase != TouchPhase.ENDED) onStartDrag(_selectIndex);
		}
		
		private function dragDropHandler(event:DragDropEvent, dragData:DragData):void
		{
			dropping = event.currentTarget as ItemRenderer;
		}
		private function dragCompleteHandler(event:DragDropEvent, dragData:DragData):void
		{
			var itemDrag:Object = dropping;
			if( TreeUtil.isSelf(tree, itemDrag, dragging) ) return;
			var newIndex:Vector.<int>;
			var isDirectory:Boolean;
			if(!itemDrag.isDirectory)
			{
				TreeUtil.move( dataProvider, itemDrag, dragging, isBefore( itemDrag ) );
				newIndex = this.getItemIndex( dragging );
			}
			else
			{
				switch(areaBD(itemDrag))
				{
					case "top":
						TreeUtil.move( dataProvider, itemDrag, dragging, true );
						newIndex = this.getItemIndex( dragging );
						break;
					case "bottom":
						TreeUtil.move( dataProvider, itemDrag, dragging, false );
						newIndex = this.getItemIndex( dragging );
						break;
					case "middle":
						TreeUtil.moveNext( dataProvider, itemDrag, dragging );
						isDirectory = true;
						newIndex = this.getItemIndex( dropping );
						break;
				}
			}
			this._selectedIndex = dragging.isSelected ? this.getItemIndex( dragging ) : null;
			
			dispatchEvent(new DragDropTreeEvent( DragDropTreeEvent.DRAG_COMPLETE, newIndex, this.draggingIndex, isDirectory));
		}
		private function isBefore(itemDrag:Object):Boolean
		{
			var mouse:Point = touch.getLocation(stage);
			var pt:Point = itemDrag.localToGlobal(new Point (0, 0));
			var rect:Rectangle = new Rectangle(pt.x, pt.y, itemDrag.width, itemDrag.height / 2);
			if(rect.containsPoint( mouse ))
			{
				return true;
			}
			return false;
		}
		private function areaBD(itemDrag:Object):String
		{
			var mouse:Point = touch.getLocation(stage);
			var pt:Point = itemDrag.localToGlobal(new Point (0, 0));
			var rect:Rectangle = new Rectangle(pt.x, pt.y, itemDrag.width, itemDrag.height / 3);
			if(rect.containsPoint( mouse )) return "top";
			rect = new Rectangle(pt.x, pt.y + itemDrag.height / 3, itemDrag.width, itemDrag.height / 3);
			if(rect.containsPoint( mouse )) return "middle";
			rect = new Rectangle(pt.x, pt.y + itemDrag.height * 2 / 3, itemDrag.width, itemDrag.height / 3);
			if(rect.containsPoint( mouse )) return "bottom";
			return null;
		}
		private function takeScreenshot(starling:Starling, displayObject:DisplayObject):BitmapData
		{
			var result:BitmapData = new BitmapData(displayObject.width, displayObject.height, true, 0);
			var stage:Stage = starling.stage;
			var painter:Painter = starling.painter;
			
			painter.pushState();
			painter.state.renderTarget = null;
			painter.state.setProjectionMatrix(0, 0, stage.stageWidth*stage.starling.contentScaleFactor, stage.stageHeight*stage.starling.contentScaleFactor, stage.stageWidth, stage.stageHeight, stage.cameraPosition);
			painter.clear();
			displayObject.render(painter);
			painter.finishMeshBatch();
			painter.context.drawToBitmapData(result);
			painter.popState();
			
			return result;
		}
		private var verticalLayout:VerticalLayout = new VerticalLayout();
		private var _verticalLayout:VerticalLayout = new VerticalLayout();
		private function createItemRenderer(myObject:Object):Object
		{
			var itemDrag:Object = new ItemRenderer();
			itemDrag.owner = this;
			itemDrag.addEventListener(DragDropEvent.DRAG_ENTER, dragEnterHandler);
			itemDrag.addEventListener(DragDropEvent.DRAG_DROP, dragDropHandler);
			itemDrag.addEventListener(DragDropEvent.DRAG_COMPLETE, dragCompleteHandler);
			itemDrag.name = "index";
			itemDrag.object = myObject;
			itemDrag.isDirectory = false;
			itemDrag.treeChangeHandler();
			itemDrag.layoutGroupIndex = itemDrag;
			return itemDrag
		}
		/**
		 * @private
		 */
		public function addItemRenderer(myObject:Object, layoutGroup:Object, index:int = -1):void
		{
			var itemDrag:Object = createItemRenderer( myObject );
			if(index == -1)
			{
				layoutGroup.addChild( itemDrag );
			}
			else
			{
				layoutGroup.addChildAt( itemDrag, index );
			}
			if(selectedIndex)
			{
				if(this.getItemIndex(itemDrag).join(",") == selectedIndex.join(","))
				{
					itemDrag.selectedLines();
					itemDrag.isSelected = true;
				}
			}
		}
		private function createLayout(myObject:Object):LayoutGroup
		{
			var _layoutGroup:LayoutGroup = new LayoutGroup();
			_layoutGroup.name = "index";
			_layoutGroup.layout = _verticalLayout;
			
			var subLayoutGroup:LayoutGroup = new LayoutGroup();
			verticalLayout.paddingLeft = indent;
			subLayoutGroup.layout = verticalLayout;
			
			var itemDrag:Object = new ItemRenderer();
			itemDrag.owner = this;
			itemDrag.isDirectory = true;
			itemDrag.addEventListener(DragDropEvent.DRAG_ENTER, dragEnterHandler);
			itemDrag.addEventListener(DragDropEvent.DRAG_DROP, dragDropHandler);
			itemDrag.addEventListener(DragDropEvent.DRAG_COMPLETE, dragCompleteHandler);
			itemDrag.layoutGroupIndex = _layoutGroup;
			itemDrag.layoutGroup = subLayoutGroup;
			itemDrag.object = myObject;
			itemDrag.treeChangeHandler();
			_layoutGroup.addChild( itemDrag as DisplayObject);
			
			_layoutGroup.addChild( subLayoutGroup );
			
			return _layoutGroup;
		}
		/**
		 * @private
		 */
		public function addLayout(myObject:Object, layoutGroup:Object, index:int = -1):void
		{
			if(index == -1)
			{
				layoutGroup.addChild( createLayout( myObject ) );
			}
			else
			{
				layoutGroup.addChildAt( createLayout( myObject ), index );
			}
		}
		private function onClickBD(itemDrag:Object, click:Boolean = true, unselect:Boolean = false):void
		{
			var index:Vector.<int> = this.getItemIndex( itemDrag );
			if(!unselect) dispatchEvent(new TreeEvent( TreeEvent.SELECT, index, itemDrag.isDirectory, itemDrag.object, itemDrag ));
			
			if(itemDrag.isDirectory)
			{
				if(!itemDrag.isOpen)
				{
					itemDrag.object = this.getItemJsonAt( index );
					if(itemDrag.object.children.length != 0)
					{
						itemDrag.arrow.source = itemDrag.itemDownArrowTexture;
						if(!animate) TreeUtil.createItemRenderer(itemDrag.object, this, itemDrag.layoutGroup);
						itemDrag.isOpen = true;
						if(animate) itemDrag.openItem();
					}
				}
				else
				{
					itemDrag.arrow.source = itemDrag.itemRightArrowTexture;
					if(!animate) itemDrag.layoutGroup.removeChildren();
					itemDrag.isOpen = false;
					if(animate) itemDrag.closeItem();
				}
			}
			else
			{
				if(selectable)
				{
					itemDrag.selectedLines();
					itemDrag.isSelected = !itemDrag.isSelected;
					if(click)
					{
						if(this.selectedIndex)
						{
							if(index.join(",") != this.selectedIndex.join(",")) this.unselect();
						}
						this._selectedIndex = itemDrag.isSelected ? index : null;
					}
				}
			}
		}
		
		private var dragTabScrollEdgeStart:int = 20;
		private var dragTabScrollEdgeSpeed:int = 4;
		private function EnterFrameDragHandler():void {
			if(this.viewPort.height > this.height)
			{
				if(mouse.y > 0 && mouse.y <= dragTabScrollEdgeStart / 2)
				{
					this.verticalScrollPosition -= dragTabScrollEdgeSpeed;
					if(this.verticalScrollPosition < 0) this.verticalScrollPosition = 0;
				}
				else if(mouse.y > dragTabScrollEdgeStart / 2 && mouse.y <= dragTabScrollEdgeStart)
				{
					this.verticalScrollPosition -= dragTabScrollEdgeSpeed / 2;
					if(this.verticalScrollPosition < 0) this.verticalScrollPosition = 0;
				}
				else if(mouse.y >= this.height - dragTabScrollEdgeStart && mouse.y < this.height - dragTabScrollEdgeStart / 2)
				{
					this.verticalScrollPosition += dragTabScrollEdgeSpeed / 2;
					if(this.verticalScrollPosition > this.maxVerticalScrollPosition) this.verticalScrollPosition = this.maxVerticalScrollPosition;
				}
				else if(mouse.y >= this.height - dragTabScrollEdgeStart / 2 && mouse.y < this.height)
				{
					this.verticalScrollPosition += dragTabScrollEdgeSpeed;
					if(this.verticalScrollPosition > this.maxVerticalScrollPosition) this.verticalScrollPosition = this.maxVerticalScrollPosition;
				}
			}
			if(this.viewPort.width > this.width)
			{
				if(mouse.x > 0 && mouse.x <= dragTabScrollEdgeStart / 2)
				{
					this.horizontalScrollPosition -= dragTabScrollEdgeSpeed;
					if(this.horizontalScrollPosition < 0) this.horizontalScrollPosition = 0;
				}
				else if(mouse.x > dragTabScrollEdgeStart / 2 && mouse.x <= dragTabScrollEdgeStart)
				{
					this.horizontalScrollPosition -= dragTabScrollEdgeSpeed / 2;
					if(this.horizontalScrollPosition < 0) this.horizontalScrollPosition = 0;
				}
				else if(mouse.x >= this.width - dragTabScrollEdgeStart && mouse.x < this.width - dragTabScrollEdgeStart / 2)
				{
					this.horizontalScrollPosition += dragTabScrollEdgeSpeed / 2;
					if(this.horizontalScrollPosition > this.maxHorizontalScrollPosition) this.horizontalScrollPosition = this.maxHorizontalScrollPosition;
				}
				else if(mouse.x >= this.width - dragTabScrollEdgeStart / 2 && mouse.x < this.width)
				{
					this.horizontalScrollPosition += dragTabScrollEdgeSpeed;
					if(this.horizontalScrollPosition > this.maxHorizontalScrollPosition) this.horizontalScrollPosition = this.maxHorizontalScrollPosition;
				}
			}
		}
		
		private var separator:int = 2;
		private var separatorBD:Object;
		/**
		 * @private
		 */
		public function onSeparator(itemDrag:Object, pt:Point):void
		{
			if( TreeUtil.isSelf(tree, itemDrag, dragging) )
			{
				removeSeparator();
				return;
			}
			if(!itemDrag.quad)
			{
				itemDrag.quad = new Quad(dragging.width, separator);
				itemDrag.quad.color = 0xffffff;
				this.addChild(itemDrag.quad);
			}
			itemDrag.quad.x = pt.x;
			itemDrag.quad.width = itemDrag.width;
			itemDrag.quad.height = separator;
			if(!itemDrag.isDirectory)
			{
				itemDrag.quad.y = isBefore(itemDrag) ? pt.y - separator / 2 : pt.y + itemDrag.height - separator / 2;
			}
			else if(!itemDrag.isOpen)
			{
				switch(areaBD(itemDrag))
				{
					case "top":
						itemDrag.quad.y = pt.y - separator / 2;
						break;
					
					case "middle":
						itemDrag.quad.x = pt.x + itemDrag.width - separator;
						itemDrag.quad.y = pt.y;
						itemDrag.quad.width = separator;
						itemDrag.quad.height = itemDrag.height;
						break;
					
					case "bottom":
						itemDrag.quad.y = pt.y + itemDrag.height - separator / 2;
						break;
				}
			}
			else
			{
				switch(areaBD(itemDrag))
				{
					case "top":
						itemDrag.quad.y = pt.y - separator / 2;
						break;
					
					case "middle":
						itemDrag.quad.x = pt.x + verticalLayout.paddingLeft;
						itemDrag.quad.y = pt.y + itemDrag.height + itemDrag.layoutGroup.height - separator / 2;
						itemDrag.quad.width = itemDrag.layoutGroup.getChildAt( itemDrag.layoutGroup.numChildren - 1 ).width;
						break;
					
					case "bottom":
						var position:int = itemDrag.parent.parent.getChildIndex(itemDrag.parent);
						if(position != itemDrag.parent.parent.numChildren - 1)
						{
							var container:Object = itemDrag.parent.parent.getChildAt( position + 1 );
							var itemDragNext:Object = container is LayoutGroup ? container.getChildAt(0) as ItemRenderer : container as ItemRenderer;
							var ptNext:Point = itemDragNext.localToGlobal(new Point (0, 0));
							ptNext = this.globalToLocal(ptNext);
							itemDrag.quad.width = itemDragNext.width;
							itemDrag.quad.y = ptNext.y - separator / 2;
						}
						else
						{
							itemDrag.quad.y = pt.y + itemDrag.height + itemDrag.layoutGroup.height - separator / 2;
							itemDrag.quad.width = dragging.width;
						}
						break;
				}
			}
			if(separatorBD != itemDrag)
			{
				removeSeparator();
				separatorBD = itemDrag;
			}
		}
		/**
		 * @private
		 */
		public function removeSeparator():void
		{
			if(separatorBD)
			{
				this.removeChild(separatorBD.quad);
				separatorBD.quad = null;
			}
		}
		/**
		 * Get the index of an item at the specified index.
		 *
		 * @param myObject a tree item
		 */
		public function getItemIndex(myObject:Object):Vector.<int>
		{
			var index:Vector.<int> = new <int>[];
			while(myObject != tree)
			{
				if(myObject.name == "index") index.unshift( myObject.parent.getChildIndex(myObject) );
				myObject = myObject.parent;
			}
			return index;
		}
		/**
		 * Replace a tree item at the specified index.
		 *
		 * @param object the new item
		 *
		 * @param index row index of the tree
		 */
		public function setItemAt(item:Object, index:Vector.<int>):void
		{
			var myObject:Object = tree;
			var update:Boolean;
			var position:int;
			var layoutGroup:LayoutGroup;
			for(var i:int = 0; i < index.length; i++)
			{
				myObject = myObject.getChildAt( index[i] );
				if(i != index.length - 1)
				{
					if(!myObject.getChildAt(0).isOpen)
					{
						myObject = null;
						break;
					}
					else
					{
						myObject = myObject.getChildAt(1);
					}
				}
				else
				{
					if(!myObject.hasOwnProperty("object"))
					{
						myObject = myObject.getChildAt(0);
						if( JSON.stringify(myObject.object) != JSON.stringify(item) )
						{
							if( myObject.object.hasOwnProperty("children"))
							{
								if( item.hasOwnProperty("children") )
								{
									if( JSON.stringify(myObject.object.children) == JSON.stringify(item.children) )
									{
										update = true;
									}
									else
									{
										position = myObject.parent.getChildIndex( myObject );
										layoutGroup = myObject.parent;
										layoutGroup.removeChildAt( position );
										layoutGroup.addChildAt( createLayout( item ), position );
									}
								}
								else
								{
									position = myObject.parent.getChildIndex( myObject );
									layoutGroup = myObject.parent;
									layoutGroup.removeChildAt( position );
									layoutGroup.addChildAt( createItemRenderer( item ) as DisplayObject, position );
								}
							}
							else
							{
								if( item.hasOwnProperty("children") )
								{
									position = myObject.parent.getChildIndex( myObject );
									layoutGroup = myObject.parent;
									layoutGroup.removeChildAt( position );
									layoutGroup.addChildAt( createLayout( item ), position );
								}
								else
								{
									update = true;
								}
							}
						}
					}
					else
					{
						update = true;
					}
				}
			}
			var itemParent:Object = this.getItemJsonParentAt( index );
			itemParent[ index[ index.length - 1 ] ] = item;
			if(update)
			{
				myObject.object = item;
				myObject.treeChangeHandler();
			}
		}
		/**
		 * Get the json item associated with the tree (dataProvider) at the specified index.
		 *
		 * @param index row index of the tree
		 */
		public function getItemJsonAt(index:Vector.<int>):Object
		{
			var myObject:Object;
			for(var i:int = 0; i < index.length; i++)
			{
				if(i == 0)
				{
					myObject = dataProvider[ index[i] ];
				}
				else
				{
					myObject = myObject.children[ index[i] ];
				}
			}
			return myObject;
		}
		/**
		 * Get the json item parent associated with the tree (dataProvider) at the specified index.
		 *
		 * @param index row index of the tree
		 */
		public function getItemJsonParentAt(index:Vector.<int>):Object
		{
			var _index:Vector.<int> = index.concat();
			_index.pop();
			var itemParent:Object = getItemJsonAt( _index );
			return itemParent ? itemParent.children : dataProvider;
		}
		private function selectTouchIndex(target:Object):Object
		{
			while (!target.hasOwnProperty("object"))
			{
				target = target.parent;
			}
			return target;
		}
		/**
		 * Open the the tree control at the specified index.
		 *
		 * @param index row index of the tree
		 */
		public function open(index:Vector.<int>):void
		{
			var myObject:Object = tree;
			for(var i:int = 0; i < index.length; i++)
			{
				myObject = myObject.getChildAt( index[i] );
				if(!myObject.hasOwnProperty("object"))
				{
					var itemDrag:Object = myObject.getChildAt(0);
					myObject = myObject.getChildAt(1);
					if(!itemDrag.isOpen)
					{
						if(itemDrag.object.children.length == 0) continue;
						itemDrag.arrow.source = itemDrag.itemDownArrowTexture;
						TreeUtil.createItemRenderer(itemDrag.object, this, itemDrag.layoutGroup);
						itemDrag.isOpen = true;
					}
				}
			}
		}
		/**
		 * Close the the tree control at the specified index.
		 *
		 * @param index row index of the tree
		 */
		public function close(index:Vector.<int>):void
		{
			var myObject:Object = tree;
			for(var i:int = 0; i < index.length; i++)
			{
				myObject = myObject.getChildAt( index[i] );
				if( !myObject.hasOwnProperty("object") ) myObject = myObject.getChildAt(1);
				if(i < index.length - 1) continue;
				if( myObject.hasOwnProperty("object") ) myObject = myObject.parent;
				var itemDrag:Object = myObject.parent.getChildAt(0);
				if(itemDrag.isOpen)
				{
					if(itemDrag.object.children.length == 0) continue;
					itemDrag.arrow.source = itemDrag.itemRightArrowTexture;
					itemDrag.layoutGroup.removeChildren();
					itemDrag.isOpen = false;
				}
			}
		}
		
		private var _selectedIndex:Vector.<int>;
		/**
		 * The index of the currently selected item. It's a Vector.&lt;int&gt;.
		 */
		public function get selectedIndex():Vector.<int>
		{
			return _selectedIndex;
		}
		public function set selectedIndex(value:Vector.<int>):void
		{
			if(!selectable) return;
			this.unselect();
			_selectedIndex = value;
			if( isItemOpenAt(selectedIndex) ) onClickBD( this.getItemAt(selectedIndex), false );
		}
		private function unselect():void
		{
			if(selectedIndex)
			{
				if( isItemOpenAt(selectedIndex) ) onClickBD( this.getItemAt(selectedIndex), false, true );
			}
		}
		
		/**
		 * Indicates whether an item is Open.
		 *
		 * @param index row index of the tree
		 */
		public function isItemOpenAt(index:Vector.<int>):Boolean
		{
			var myObject:Object = tree;
			for(var i:int = 0; i < index.length; i++)
			{
				myObject = myObject.getChildAt( index[i] );
				if(!myObject.hasOwnProperty("object"))
				{
					var itemDrag:Object = myObject.getChildAt(0);
					myObject = myObject.getChildAt(1);
					if(!itemDrag.isOpen)
					{
						return false;
					}
				}
			}
			return true;
		}
		
		/**
		 * Get a tree item at the specified index.
		 *
		 * @param index row index of the tree
		 */
		public function getItemAt(index:Vector.<int>):Object
		{
			var myObject:Object = tree;
			for(var i:int = 0; i < index.length; i++)
			{
				myObject = myObject.getChildAt( index[i] );
				if( i != index.length - 1 )
				{
					myObject = myObject.getChildAt(1);
				}
			}
			return myObject;
		}
		
		/**
		 * Add a tree item in the specified index. It's necessary that the item is a branch.
		 *
		 * @param object the new item
		 *
		 * @param index row index of the tree
		 */
		public function addItemAt(item:Object, index:Vector.<int>):void
		{
			if(!this.dataProvider) this.dataProvider = [];
			var myObject:Object = tree;
			for(var i:int = 0; i < index.length; i++)
			{
				if(myObject.numChildren != 0) myObject = myObject.getChildAt( index[i] );
				if(i != index.length - 1)
				{
					if(!myObject.getChildAt(0).isOpen)
					{
						break;
					}
					else
					{
						myObject = myObject.getChildAt(1);
					}
				}
				else
				{
					if(myObject.numChildren != 0) myObject = myObject.getChildAt(1);
					if(item.hasOwnProperty("children"))
					{
						this.addLayout(item, myObject);
					}
					else
					{
						this.addItemRenderer(item, myObject);
					}
				}
			}
			
			var itemParent:Object = this.getItemJsonAt( index );
			itemParent.children.push( item );
		}
		
		/**
		 * Add a tree item before the specified index.
		 *
		 * @param object the new item
		 *
		 * @param index row index of the tree
		 */
		public function addItemBefore(item:Object, index:Vector.<int>):void
		{
			if(!this.dataProvider) this.dataProvider = [];
			var myObject:Object = tree;
			var endIndex:int = index[ index.length - 1 ];
			for(var i:int = 0; i < index.length; i++)
			{
				if(myObject.numChildren != 0) myObject = myObject.getChildAt( index[i] );
				if(i != index.length - 1)
				{
					if(!myObject.getChildAt(0).isOpen)
					{
						break;
					}
					else
					{
						myObject = myObject.getChildAt(1);
					}
				}
				else
				{
					if(myObject.numChildren != 0) myObject = myObject.parent;
					if(item.hasOwnProperty("children"))
					{
						this.addLayout(item, myObject, endIndex); 
					}
					else
					{
						this.addItemRenderer(item, myObject, endIndex);
					}
				}
			}
			
			var itemParent:Object = this.getItemJsonParentAt( index );
			itemParent.splice( endIndex, 0, item);
		}
		
		/**
		 * Add a tree item after the specified index.
		 *
		 * @param object the new item
		 *
		 * @param index row index of the tree
		 */
		public function addItemAfter(item:Object, index:Vector.<int>):void
		{
			if(!this.dataProvider) this.dataProvider = [];
			var myObject:Object = tree;
			var endIndex:int = index[ index.length - 1 ];
			for(var i:int = 0; i < index.length; i++)
			{
				if(myObject.numChildren != 0) myObject = myObject.getChildAt( index[i] );
				if(i != index.length - 1)
				{
					if(!myObject.getChildAt(0).isOpen)
					{
						break;
					}
					else
					{
						myObject = myObject.getChildAt(1);
					}
				}
				else
				{
					if(myObject.numChildren != 0) myObject = myObject.parent;
					if(myObject.numChildren != endIndex)
					{
						if(item.hasOwnProperty("children"))
						{
							this.addLayout(item, myObject, endIndex + 1);
						}
						else
						{
							this.addItemRenderer(item, myObject, endIndex + 1);
						}
					}
					else
					{
						if(item.hasOwnProperty("children"))
						{
							this.addLayout(item, myObject); 
						}
						else
						{
							this.addItemRenderer(item, myObject);
						}
					}
				}
			}
			
			var itemParent:Object = this.getItemJsonParentAt( index );
			if(itemParent.length != endIndex)
			{
				itemParent.splice( endIndex + 1, 0, item);
			}
			else
			{
				itemParent.push(item);
			}
		}
		
		/**
		 * Remove a tree item at the specified index.
		 *
		 * @param index row index of the tree
		 */
		public function removeItemAt(index:Vector.<int>):void
		{
			var myObject:Object = tree;
			var endIndex:int = index[ index.length - 1 ];
			for(var i:int = 0; i < index.length; i++)
			{
				myObject = myObject.getChildAt( index[i] );
				if(i != index.length - 1)
				{
					if(!myObject.getChildAt(0).isOpen)
					{
						break;
					}
					else
					{
						myObject = myObject.getChildAt(1);
					}
				}
				else
				{
					myObject.parent.removeChildAt( endIndex );
				}
			}
			
			var itemParent:Object = this.getItemJsonParentAt( index );
			itemParent.splice( endIndex, 1 );
		}
		/**
		 * Remove json item children at the specified index.
		 *
		 * @param index row index of the tree
		 */
		public function removeJsonChildrenAt(index:Vector.<int>):void
		{
			var item:Object = this.getItemJsonAt( index );
			item.children = [];
		}
		
		/**
		 * Indicates whether an item exist.
		 *
		 * @param index row index of the tree
		 */
		public function hasItemAt(index:Vector.<int>):Boolean
		{
			var myObject:Object;
			for(var i:int = 0; i < index.length; i++)
			{
				if(i == 0)
				{
					if(index[i] > dataProvider.length - 1) return false;
					myObject = dataProvider[ index[i] ];
				}
				else
				{
					if( !myObject.hasOwnProperty("children") ) return false;
					if(index[i] > myObject.children.length - 1) return false;
					myObject = myObject.children[ index[i] ];
				}
			}
			return true;
		}
		
		/**
		 * Get the path of the specified item.
		 *
		 * @param index row index of the tree
		 *
		 * @param separator the separator path
		 *
		 * @param key the key of the json item object who will serve for the path
		 */
		public function getPathAt(index:Vector.<int>, separator:String = "/", key:String = "name"):String
		{
			var path:String = "";
			var myObject:Object;
			for(var i:int = 0; i < index.length; i++)
			{
				if(i == 0)
				{
					myObject = dataProvider[ index[i] ];
					path += myObject[key];
					if(i != index.length - 1) path += separator;
				}
				else
				{
					myObject = myObject.children[ index[i] ];
					path += myObject[key];
					if(i != index.length - 1) path += separator;
				}
			}
			return path;
		}
		
		/**
		 * Scroll to the index currently selected in the tabBar.
		 */
		public function scrollToIndex(index:Vector.<int>):void
		{
			callLater(scrollToIndexCL, [index]);
		}
		private function scrollToIndexCL(index:Vector.<int>):void
		{
			var myObject:Object = this.getItemAt( index );
			//itemValidate(myObject);
			var pt:Point = myObject.localToGlobal(new Point (0, 0));
			pt = this.globalToLocal(pt);
			
			if(this.viewPort.width > this.viewPort.visibleWidth)
			{				
				if(myObject.width > this.viewPort.visibleWidth) //item width > this width
				{
					this.horizontalScrollPosition = pt.x; //item begin
				}
				else if(pt.x < this.horizontalScrollPosition) //item begin < this begin
				{
					this.horizontalScrollPosition = pt.x; //item begin
				}
				else if(pt.x + myObject.width > this.horizontalScrollPosition + this.viewPort.visibleWidth) //item end > this end
				{
					this.horizontalScrollPosition = pt.x + myObject.width - this.viewPort.visibleWidth; //item end - this width
				}
			}
			
			if(this.viewPort.height > this.viewPort.visibleHeight)
			{				
				if(myObject.height > this.viewPort.visibleHeight) //item height > this height
				{
					this.verticalScrollPosition = pt.y; //item begin
				}
				else if(pt.y < this.verticalScrollPosition) //item begin < this begin
				{
					this.verticalScrollPosition = pt.y; //item begin
				}
				else if(pt.y + myObject.height > this.verticalScrollPosition + this.viewPort.visibleHeight) //item end > this end
				{
					this.verticalScrollPosition = pt.y + myObject.height - this.viewPort.visibleHeight; //item end - this height
				}
			}
		}
		/**
		 * @private 
		 */
		public function rowChange(index:Vector.<int>, isDirectory:Boolean, object:Object, item:Object):void
		{
			dispatchEvent(new TreeEvent( TreeEvent.CHANGE, index, isDirectory, object, item ));
		}
		
		private var _animate:Boolean = false;
		/**
		 * Determines if open and close item has animate.
		 *
		 * @default false
		 */
		public function get animate():Boolean
		{
			return this._animate;
		}
		public function set animate(value:Boolean):void
		{
			this._animate = value;
		}
		
		/*private function itemValidate(item:Object):void
		{
			item.validate();
			while(item.parent != this)
			{
				item = item.parent;
				item.validate();
			}
			this.validate();
		}*/
		
		/**
		 * @private
		 */
		override public function dispose():void
		{
			tree.layout = null;
			tree.removeEventListener(TouchEvent.TOUCH, touchHandler);
			TreeUtil.dispose(tree);
			super.dispose();
		}
	}
}
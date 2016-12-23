package com.examples
{
	import feathers.extensions.tree.events.TreeEvent;
	import components.CustomTreeItemRenderer;
	import feathers.extensions.tree.Tree;
	import feathers.controls.LayoutGroup;
	import flash.filesystem.File;
	import flash.display.Bitmap;
	import feathers.themes.MetalWorksDesktopTheme;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class FileExplorer extends LayoutGroup
	{
		private var tree:Tree;
		
		[Embed(source="./spritesheet/images/mediumIcons.png")]
		private const imageSpriteSheet:Class;
		[Embed(source="./spritesheet/images/mediumIcons.xml", mimeType="application/octet-stream")]
		private const atlas:Class;
		private var xml:XML = XML(new atlas());
		private var bitmap:Bitmap = new imageSpriteSheet();
		private var texture:Texture = Texture.fromBitmap(bitmap, false, false, 2);
		private var textureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
		private var fileTexture:Texture = textureAtlas.getTexture("file-icon0000");
		private var folderTexture:Texture = textureAtlas.getTexture("folder-icon0000");
		private var itemRightArrowTexture:Texture = textureAtlas.getTexture("right-arrow-icon0000");
		private var itemDownArrowTexture:Texture = textureAtlas.getTexture("down-arrow-icon0000");
		
		public function FileExplorer()
		{
			new MetalWorksDesktopTheme();
			super();
			
			tree = new Tree(); 
			tree.width = 400;
			tree.height = 400;
			tree.itemRenderer = components.CustomTreeItemRenderer;
			tree.addEventListener(TreeEvent.SELECT, changeHandler);
			addChild(tree);
			
			init();
		}
		
		private function init():void
		{
			var directory:File = File.getRootDirectories()[0];
			var list:Array = directory.getDirectoryListing();
			for (var i:uint = 0; i < list.length; i++) {
				if(list[i].isDirectory)
				{
					tree.addItemAfter( { name:list[i].name, children:[], fileTexture:folderTexture, itemRightArrowTexture:itemRightArrowTexture, itemDownArrowTexture:itemDownArrowTexture }, new <int>[ i - 1 ] );
				}
				else
				{
					tree.addItemAfter( { name:list[i].name, fileTexture:fileTexture }, new <int>[ i - 1 ] );
				}
			}
		}
		private function changeHandler( event:TreeEvent ):void
		{
			if(event.isDirectory)
			{
				if(event.item.isOpen)
				{
					tree.removeJsonChildrenAt( event.index );
					return;
				}
				var directory:File = File.getRootDirectories()[0].resolvePath(tree.getPathAt(event.index));
				var list:Array = directory.getDirectoryListing();
				for (var i:uint = 0; i < list.length; i++) {
					if(list[i].isDirectory)
					{
						event.index.push( i - 1 );
							tree.addItemAfter( { name:list[i].name, children:[], fileTexture:folderTexture, itemRightArrowTexture:itemRightArrowTexture, itemDownArrowTexture:itemDownArrowTexture }, event.index );
						event.index.pop();
					}
					else
					{
						event.index.push( i - 1 );
							tree.addItemAfter( { name:list[i].name, fileTexture:fileTexture }, event.index );
						event.index.pop();
					}
				}
			}
		}
	}
}
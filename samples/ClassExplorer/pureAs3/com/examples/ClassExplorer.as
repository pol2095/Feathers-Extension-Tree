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
	
	public class ClassExplorer extends LayoutGroup
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
		
		private var json:Object = [
			{
				"name": "Flash Forums",
				"type": "url",
				"fileTexture":fileTexture
			},
			{
				"name": "Apache Flex forum",
				"type": "url",
				"fileTexture":fileTexture
			},
			{
				"name": "Starling",
				"fileTexture":folderTexture,
				"itemRightArrowTexture":itemRightArrowTexture,
				"itemDownArrowTexture":itemDownArrowTexture,
				"children": [
					{
						"name": "Feathers",
						"type": "url",
						"fileTexture":fileTexture
					},
					{
						"name": "display",
						"fileTexture":folderTexture,
						"itemRightArrowTexture":itemRightArrowTexture,
						"itemDownArrowTexture":itemDownArrowTexture,
						"children": [
							{
								"name": "Button",
								"type": "url",
								"fileTexture":fileTexture
							},
							{
								"name": "Canvas",
								"type": "url",
								"fileTexture":fileTexture
							}
						]
					}
				]
			}
		];
		
		public function ClassExplorer()
		{
			new MetalWorksDesktopTheme();
			super();
			
			var tree:Tree = new Tree(); 
			tree.width = 400;
			tree.height = 400;
			tree.itemRenderer = components.CustomTreeItemRenderer;
			tree.addEventListener(TreeEvent.SELECT, selectHandler);
			addChild(tree);
			
			tree.dataProvider = json;
		}
		
		private function selectHandler( event:TreeEvent ):void
		{
			trace( event.data.name );
		}
	}
}
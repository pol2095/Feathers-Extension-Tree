package components
{
	import feathers.extensions.tree.TreeItemRenderer;
	import starling.textures.Texture;
	import feathers.layout.HorizontalLayout;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	
	public class CustomTreeItemRenderer extends TreeItemRenderer
	{
		public var itemRightArrowTexture:Texture;
		public var itemDownArrowTexture:Texture;
		
		private var dir:ImageLoader;
		private var label:Label;
		public var arrow:ImageLoader;
		
		public function CustomTreeItemRenderer()
		{
			super();
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.verticalAlign = "middle";
			this.layout = horizontalLayout;
			
			dir = new ImageLoader();
			this.addChild( dir );
			
			label = new Label();
			this.addChild( label );
			
			arrow = new ImageLoader();
			this.addChild( arrow );
		}
		
		override public function treeChangeHandler():void
		{
			super.treeChangeHandler(); //never forget to add this!
			
			label.text = this.data.name;
			dir.source = this.data.fileTexture;
			if(isDirectory)
			{
				itemRightArrowTexture = this.data.itemRightArrowTexture;
				itemDownArrowTexture = this.data.itemDownArrowTexture;
				arrow.source = itemRightArrowTexture;
			}
		}
		
		override protected function rowChangeHandler():void
		{
			if(isChanging) return; //never forget to add this!
			
			//your code
			
			super.rowChangeHandler(); //never forget to add this!
		}
	}
}
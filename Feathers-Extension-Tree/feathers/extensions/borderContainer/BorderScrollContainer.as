/*
Copyright 2018 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.borderContainer
{
	import feathers.controls.ScrollContainer;
	import feathers.skins.IStyleProvider;

	public class BorderScrollContainer extends ScrollContainer
	{
		/**
		 * The default <code>IStyleProvider</code> for all <code>BorderScrollContainer</code>
		 * components.
		 *
		 * @default null
		 * @see feathers.core.FeathersControl#styleProvider
		 */
		public static var globalStyleProvider:IStyleProvider;

		/**
		 * Constructor.
		 */
		public function BorderScrollContainer()
		{
			super();
		}

		/**
		 * @private
		 */
		override protected function get defaultStyleProvider():IStyleProvider
		{
			return BorderScrollContainer.globalStyleProvider;
		}
	}
}

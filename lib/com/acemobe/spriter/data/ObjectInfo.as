package com.acemobe.spriter.data
{
	import com.acemobe.spriter.SpriterAnimation;

	public class ObjectInfo
	{
		public	static	var	BOX:int = 0;
		public	static	var	BONE:int = 1;
		
		public	var	name:String = "";
		public	var	type:int = 0;
		public	var	w:Number;
		public	var	h:Number;
		public	var	pivot_x:Number;
		public	var	pivot_y:Number;

		public function ObjectInfo()
		{
		}
		
		public	function parseXML (spriteAnim:SpriterAnimation, objectInfoXml:XML):void
		{
			name = objectInfoXml.@name;
			w = objectInfoXml.@w;
			h = objectInfoXml.@h;
			
			if (objectInfoXml.hasOwnProperty("@pivot_x"))
				pivot_x = objectInfoXml.@pivot_x;
			if (objectInfoXml.hasOwnProperty("@pivot_y"))
				pivot_y = objectInfoXml.@pivot_y;

			if (objectInfoXml.hasOwnProperty("@type"))
			{
				if (objectInfoXml.@type == "box")
					type = BOX;
				else if (objectInfoXml.@type == "bone")
					type = BONE;
			}
		}

		public	function parse (spriteAnim:SpriterAnimation, objectInfoData:*):void
		{
			name = objectInfoData.name;
			w = objectInfoData.w;
			h = objectInfoData.h;
			
			if (objectInfoData.hasOwnProperty("pivot_x"))
				pivot_x = objectInfoData.pivot_x;
			if (objectInfoData.hasOwnProperty("pivot_y"))
				pivot_y = objectInfoData.pivot_y;
			
			if (objectInfoData.type == "box")
				type = BOX;
			else if (objectInfoData.type == "bone")
				type = BONE;
		}
	}
}
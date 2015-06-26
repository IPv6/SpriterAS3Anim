SpriterAS3Anim
==============

AS3 code to animate Spriter Animations in Starling.
- bone support (from com.acemobe.spriter)
- pivot_x/pivot_y support (from com.acemobe.spriter)
- curve_type=cube/quadratic/instant/linear interpolation support for keyframes (from com.acemobe.spriter)
- scml atlas automatic building/loading (from treefortress.spriter)

	var full_url:String = ...
	var spriterLoader:SpriterLoader = new SpriterLoader(
		function(loader:SpriterLoader):void { // onLoaded
			var mcspr:Spriter = new Spriter(full_url, "idle", spriterLoader.spriteXml, spriterLoader.textureAtlas);
			mcspr.playbackSpeed = 1.0;
			mcspr.setTime(0.0);
			mcspr.playAnim(null);// null -> first animation in scml
			Starling.juggler.add(mcspr);
			//addChild(mcspr);
		}, function(event:IOErrorEvent):void { // onLoadFailed
			***
		});
	spriterLoader.load([full_url], 1.0);

	

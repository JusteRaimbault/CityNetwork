

// FROM http://www.gogo3s.com/post/30


//百度图层类
	OpenLayers.Layer.BaiDu = OpenLayers.Class(OpenLayers.Layer.TMS, {
		initialize: function (name, url, options) {
			var tempoptions = OpenLayers.Util.extend({
				//numZoomLevels : 20,
				//isBaseLayer : true,
				tileOrigin : new OpenLayers.LonLat(0,28000),
				maxResolution:262144
			}, options);
			OpenLayers.Layer.TMS.prototype.initialize.apply(this, [name, url,tempoptions]);
			this.extension = 'png';
			this.transitionEffect = "resize";
			this.buffer = 0;
		},
		getURL: function (bounds) {
			var z = this.map.getZoom();
	        var res = this.map.getResolution();
	        var x = Math.round((bounds.left - this.tileOrigin.lon) / (res * this.tileSize.w));
	        var y = Math.round((bounds.bottom - this.tileOrigin.lat) / (res * this.tileSize.h));
		    if (this.maxExtent.intersectsBounds( bounds ) && z >= 1 && z <= 20 )
			{
			   return this.url + "&x=" + x + "&y=" + y + "&z=" + z;
            } else
			{
               return "";//"./none.png";
            }
		 },
		 clone: function (obj) {
			if (obj == null) {
				obj = new OpenLayers.Layer.BaiDu(this.name, this.url, this.options);
			}
			obj = OpenLayers.Layer.TMS.prototype.clone.apply(this, [obj]);
			return obj;
		},
		CLASS_NAME: "OpenLayers.Layer.BaiDu"
	});







//创建地图，加载图层
        var map;
        function init(){
				map = new OpenLayers.Map({
				div: "map",
				projection: "EPSG:900913",
				displayProjection: new OpenLayers.Projection("EPSG:4326"),
				numZoomLevels:20,
				maxExtent: new OpenLayers.Bounds(-20037508.34, -20037508.34, 20037508.34, 20037508.34),
				controls: [
						new OpenLayers.Control.Navigation(),
						new OpenLayers.Control.PanZoomBar(),
						new OpenLayers.Control.LayerSwitcher({'ascending':false}),
						new OpenLayers.Control.MousePosition(),
						new OpenLayers.Control.OverviewMap(),
						new OpenLayers.Control.KeyboardDefaults()
					],
				layers: [
					new OpenLayers.Layer.BaiDu('百度', "http://online3.map.bdimg.com/tile/?qt=tile&styles=pl",
					{
						isBaseLayer : true,
					})
			],
			center:new OpenLayers.LonLat(112.170,32.029).transform(
					new OpenLayers.Projection("EPSG:4326"),
					new OpenLayers.Projection("EPSG:900913") ),
			zoom: 5
		});

		map.addControl(new OpenLayers.Control.LayerSwitcher());
		map.addControl(new OpenLayers.Control.MousePosition());
	}

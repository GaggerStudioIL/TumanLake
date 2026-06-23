#target photoshop

app.displayDialogs = DialogModes.NO;

var PSD_PATH = "C:/Users/user/Downloads/circle.psd";
var OUT_DIR = "C:/Games/TumanLake/assets/ui/cast_depth/psd_layers_raw";
var MANIFEST_PATH = OUT_DIR + "/manifest.json";

function ensureFolder(path) {
	var folder = new Folder(path);
	if (!folder.exists) {
		folder.create();
	}
	return folder;
}

function esc(value) {
	return String(value)
		.replace(/\\/g, "\\\\")
		.replace(/"/g, "\\\"")
		.replace(/\r/g, "\\r")
		.replace(/\n/g, "\\n");
}

function safeName(value) {
	return String(value)
		.replace(/[\\\/:\*\?"<>\|]+/g, "_")
		.replace(/^\s+|\s+$/g, "")
		.replace(/\s+/g, "_")
		.substring(0, 80);
}

function layerKindName(layer) {
	try {
		if (layer.typename == "LayerSet") {
			return "group";
		}
		return String(layer.kind);
	} catch (e) {
		return "unknown";
	}
}

function boundsArray(layer) {
	try {
		var b = layer.bounds;
		return [
			Number(b[0].as("px")),
			Number(b[1].as("px")),
			Number(b[2].as("px")),
			Number(b[3].as("px"))
		];
	} catch (e) {
		return [0, 0, 0, 0];
	}
}

function setAllVisibility(container, visible) {
	for (var i = 0; i < container.layers.length; i++) {
		var layer = container.layers[i];
		try {
			layer.visible = visible;
		} catch (e) {}
		if (layer.typename == "LayerSet") {
			setAllVisibility(layer, visible);
		}
	}
}

function setLayerTreeVisible(layer, visible) {
	if (visible) {
		setAncestorsVisible(layer);
	}
	try {
		layer.visible = visible;
	} catch (e) {}
	if (layer.typename == "LayerSet") {
		setAllVisibility(layer, visible);
	}
}

function setAncestorsVisible(layer) {
	var parent = layer.parent;
	while (parent != null && parent.typename == "LayerSet") {
		try {
			parent.visible = true;
		} catch (e) {}
		parent = parent.parent;
	}
}

function exportPng(doc, filePath) {
	var output = new File(filePath);
	var options = new PNGSaveOptions();
	options.compression = 9;
	options.interlaced = false;
	doc.saveAs(output, options, true, Extension.LOWERCASE);
}

function collectLayers(container, path, output) {
	for (var i = 0; i < container.layers.length; i++) {
		var layer = container.layers[i];
		var itemPath = path ? path + "/" + layer.name : layer.name;
		output.push({
			layer: layer,
			path: itemPath,
			name: layer.name,
			typename: layer.typename,
			kind: layerKindName(layer),
			bounds: boundsArray(layer)
		});
		if (layer.typename == "LayerSet") {
			collectLayers(layer, itemPath, output);
		}
	}
}

function main() {
	ensureFolder(OUT_DIR);
	var gdignore = new File(OUT_DIR + "/.gdignore");
	gdignore.open("w");
	gdignore.encoding = "UTF8";
	gdignore.write("\n");
	gdignore.close();
	var psd = new File(PSD_PATH);
	var original = app.open(psd);
	var doc = original.duplicate("circle_export_work", false);
	original.close(SaveOptions.DONOTSAVECHANGES);
	app.activeDocument = doc;

	var layers = [];
	collectLayers(doc, "", layers);
	var manifest = [];

	for (var i = 0; i < layers.length; i++) {
		var item = layers[i];
		setAllVisibility(doc, false);
		setLayerTreeVisible(item.layer, true);
		var filename = ("000" + i).slice(-3) + "_" + safeName(item.path) + ".png";
		var filePath = OUT_DIR + "/" + filename;
		exportPng(doc, filePath);
		manifest.push({
			index: i,
			file: filename,
			path: item.path,
			name: item.name,
			typename: item.typename,
			kind: item.kind,
			bounds: item.bounds
		});
	}

	var json = "[\n";
	for (var j = 0; j < manifest.length; j++) {
		var m = manifest[j];
		json += "  {\"index\":" + m.index
			+ ",\"file\":\"" + esc(m.file)
			+ "\",\"path\":\"" + esc(m.path)
			+ "\",\"name\":\"" + esc(m.name)
			+ "\",\"typename\":\"" + esc(m.typename)
			+ "\",\"kind\":\"" + esc(m.kind)
			+ "\",\"bounds\":[" + m.bounds.join(",") + "]}";
		if (j < manifest.length - 1) {
			json += ",";
		}
		json += "\n";
	}
	json += "]\n";

	var manifestFile = new File(MANIFEST_PATH);
	manifestFile.open("w");
	manifestFile.encoding = "UTF8";
	manifestFile.write(json);
	manifestFile.close();

	doc.close(SaveOptions.DONOTSAVECHANGES);
	app.quit();
}

main();

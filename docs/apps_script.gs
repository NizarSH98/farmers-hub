/**
 * Google Apps Script backend for Farmer Hub
 * Storage: a Google Sheet with columns:
 * Timestamp, Name, Phone, Email, Product, Quantity, Price, Location, HarvestDate, ImageURL, Description, Secret
 *
 * Deployment:
 * - Extensions > Apps Script
 * - Paste this code.
 * - Set SHEET_ID and SHARED_SECRET below.
 * - Deploy > Manage deployments > New deployment > Web app
 *   Who has access: Anyone
 * - Copy the Web app URL and put into both HTML files.
 */

const SHEET_ID = '1nB7frPW70jBULKBo_ssunnEip1QtfapMUzHeymvUW54';
const SHEET_NAME = 'Listings';
const SHARED_SECRET = 'farmer_hub_secret_2024_xyz';

function _sheet(){
  const ss = SpreadsheetApp.openById(SHEET_ID);
  const sh = ss.getSheetByName(SHEET_NAME) || ss.insertSheet(SHEET_NAME);
  // Ensure header
  const header = ['timestamp','name','phone','email','product','quantity','price','location','harvest_date','image_url','description','secret'];
  if (sh.getLastRow() === 0){
    sh.getRange(1,1,1,header.length).setValues([header]);
  }
  return sh;
}

function doGet(e){
  const params = e.parameter || {};
  
  // Handle listing request
  if (params.list) {
    const sh = _sheet();
    const rows = sh.getDataRange().getValues();
    const header = rows.shift();
    const data = rows
      .filter(r => (r[11] === SHARED_SECRET) || true) // keep all rows (even older ones) for listing
      .map(r => ({
        created_at: new Date(r[0]).toISOString(),
        name: r[1], phone: r[2], email: r[3],
        product: r[4], quantity: r[5], price: r[6],
        location: r[7], harvest_date: r[8], image_url: r[9], description: r[10],
      }));
    return _jsonResponse({ ok:true, rows:data });
  }
  
  // Handle form submission via GET
  if (params.action === 'submit') {
    try {
      // Basic validation
      const required = ['name','phone','product','location'];
      for (let k of required){
        if (!params[k]) return _jsonResponse({ ok:false, message:`Missing field: ${k}` }, 400);
      }

      // Simple shared secret check to reduce spam
      if (params.secret !== SHARED_SECRET){
        return _jsonResponse({ ok:false, message:'Unauthorized' }, 401);
      }

      const sh = _sheet();
      const now = new Date();
      const row = [
        now,
        _s(params.name), _s(params.phone), _s(params.email),
        _s(params.product), _s(params.quantity), _s(params.price),
        _s(params.location), _s(params.harvest_date), _s(params.image_url), _s(params.description),
        SHARED_SECRET
      ];
      sh.appendRow(row);
      return _jsonResponse({ ok:true });
    } catch (err){
      return _jsonResponse({ ok:false, message: String(err) }, 500);
    }
  }
  
  return _jsonResponse({ ok:true, message:'Farmer Hub API. Use GET with ?list=1 to fetch or ?action=submit to add.' });
}

function doPost(e){
  try{
    // Handle URL-encoded form data with 'data' parameter
    let body;
    
    if (e.parameter && e.parameter.data) {
      // URL-encoded form data - Google Apps Script already decodes it
      body = JSON.parse(e.parameter.data);
    } else if (e.postData && e.postData.contents) {
      // Direct JSON POST (fallback)
      body = JSON.parse(e.postData.contents);
    } else {
      return _jsonResponse({ ok:false, message:'No data received' }, 400);
    }
    
    if (!body) return _jsonResponse({ ok:false, message:'Invalid JSON' }, 400);

    // Basic validation
    const required = ['name','phone','product','location'];
    for (let k of required){
      if (!body[k]) return _jsonResponse({ ok:false, message:`Missing field: ${k}` }, 400);
    }

    // Simple shared secret check to reduce spam
    if (body.secret !== SHARED_SECRET){
      return _jsonResponse({ ok:false, message:'Unauthorized' }, 401);
    }

    const sh = _sheet();
    const now = new Date();
    const row = [
      now,
      _s(body.name), _s(body.phone), _s(body.email),
      _s(body.product), _s(body.quantity), _s(body.price),
      _s(body.location), _s(body.harvest_date), _s(body.image_url), _s(body.description),
      SHARED_SECRET
    ];
    sh.appendRow(row);
    return _jsonResponse({ ok:true });
  } catch (err){
    return _jsonResponse({ ok:false, message: String(err) }, 500);
  }
}

function _s(x){ return (x === undefined || x === null) ? '' : (''+x).trim(); }

function _jsonResponse(obj, status){
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

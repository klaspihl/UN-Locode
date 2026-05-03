use std::env;
use std::io::{BufRead, BufReader};
// Embed the CSV files in the binary
const CODE_LIST_CSV: &str = include_str!("code-list.csv");
const COUNTRY_CODES_CSV: &str = include_str!("country-codes.csv");

struct Args {
    name: Option<String>,
    location: Option<String>,
    country: Option<String>,
    exceptions: Option<String>,
}

fn parse_args() -> Args {
    let mut name = None;
    let mut location = None;
    let mut country = None;
    let mut exceptions = None;
    let mut args = env::args().skip(1);
    while let Some(arg) = args.next() {
        match arg.as_str() {
            "--name" | "-n" => name = args.next(),
            "--location" | "-l" => location = args.next(),
            "--country" | "-c" => country = args.next(),
            "--exceptions" | "-e" => exceptions = args.next(),
            "--locationname" => name = args.next(),
            "--city" => name = args.next(),
            _ => {},
        }
    }
    // Helper: get env var by any accepted name (case-insensitive)
    fn get_env_any<'a>(names: &[&str]) -> Option<String> {
        let vars: Vec<(String, String)> = env::vars().collect();
        for (k, v) in vars {
            let key = k.to_lowercase();
            for &n in names {
                if key == n.to_lowercase() {
                    return Some(v);
                }
            }
        }
        None
    }
    if name.is_none() {
        name = get_env_any(&["name", "locationname", "city"]);
    }
    if location.is_none() {
        location = get_env_any(&["location"]);
    }
    if country.is_none() {
        country = get_env_any(&["country"]);
    }
    if exceptions.is_none() {
        exceptions = get_env_any(&["exceptions"]);
    }
    Args { name, location, country, exceptions }
}

fn parse_csv_str(data: &str) -> Vec<Vec<String>> {
    let mut rows = Vec::new();
    for (i, line) in data.lines().enumerate() {
        if i == 0 { continue; }
        let row: Vec<String> = line.split(',').map(|s| s.trim_matches('"').to_string()).collect();
        rows.push(row);
    }
    rows
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = parse_args();

    if args.name.is_none() && args.location.is_none() && args.country.is_none() {
        println!("Usage: set environment variables or arguments:\n  --name <location name>\n  --location <UN/LOCODE short name>\n  --country <country code or name>\n\nExample (docker arguments):\n  docker run --rm klaspihl/find-unlocation --location yng --country se");
        return Ok(());
    }

    let unlocode_rows = parse_csv_str(CODE_LIST_CSV);
    let country_rows = parse_csv_str(COUNTRY_CODES_CSV);

    // --- Country normalization: allow code or name (case-insensitive) ---
    let mut country_code_opt = args.country.clone();
    if let Some(ref country_input) = args.country {
        let mut found = false;
        for crow in &country_rows {
            if crow.len() > 1 {
                if crow[0].eq_ignore_ascii_case(country_input) {
                    country_code_opt = Some(crow[0].clone());
                    found = true;
                    break;
                } else if crow[1].eq_ignore_ascii_case(country_input) {
                    country_code_opt = Some(crow[0].clone());
                    found = true;
                    break;
                }
            }
        }
        if !found {
            country_code_opt = args.country.clone();
        }
    }

    // --- Search logic ---
    let mut result = None;
    if let (Some(ref location), Some(ref country_code)) = (args.location.as_ref(), country_code_opt.as_ref()) {
        for row in &unlocode_rows {
            if row.len() > 3 && row[2].eq_ignore_ascii_case(location)
                && row[1].eq_ignore_ascii_case(country_code) {
                result = Some(row);
                break;
            }
        }
    } else if let (Some(ref name), Some(ref country_code)) = (args.name.as_ref(), country_code_opt.as_ref()) {
        for row in &unlocode_rows {
            if row.len() > 3 && row[3].eq_ignore_ascii_case(name)
                && row[1].eq_ignore_ascii_case(country_code) {
                result = Some(row);
                break;
            }
        }
    }

    if let Some(row) = result {
        let country_code = row.get(1).cloned().unwrap_or_default();
        let location_code = row.get(2).cloned().unwrap_or_default();
        let location_name = row.get(3).cloned().unwrap_or_default();
        let coordinates = row.get(10).cloned().unwrap_or_default();
        let mut country_name = String::new();
        for crow in &country_rows {
            if crow.len() > 1 && crow[0].eq_ignore_ascii_case(&country_code) {
                country_name = crow[1].clone();
                break;
            }
        }
        let coords_str = if !coordinates.is_empty() {
            convert_coordinates(&coordinates)
        } else {
            String::new()
        };
        let osm_link = if !coords_str.is_empty() {
            let mut parts = coords_str.split(',');
            if let (Some(lat), Some(lon)) = (parts.next(), parts.next()) {
                format!("https://www.openstreetmap.org/?mlat={}&mlon={}#map=11/{}/{}", lat, lon, lat, lon)
            } else {
                String::new()
            }
        } else {
            // Fallback: search by location name and country name
            let mut query = String::new();
            if !location_name.is_empty() {
                query.push_str(&location_name.replace(' ', "+"));
            }
            if !country_name.is_empty() {
                if !query.is_empty() { query.push('+'); }
                query.push_str(&country_name.replace(' ', "+"));
            }
            if !query.is_empty() {
                format!("https://www.openstreetmap.org/search?query={}", query)
            } else {
                String::new()
            }
        };
        println!(
            "{{\n  \"Location\": \"{}\",\n  \"LocatioName\": \"{}\",\n  \"Country\": \"{}\",\n  \"CountryName\": \"{}\",\n  \"Coordinates\": \"{}\",\n  \"OpenStreetMap\": \"{}\"\n}}",
            location_code, location_name, country_code, country_name, coords_str, osm_link
        );
    }
    Ok(())
}

fn convert_coordinates(coord: &str) -> String {
    // Example: "5525N 01349E"
    let parts: Vec<&str> = coord.split_whitespace().collect();
    if parts.len() != 2 { return coord.to_string(); }
    let lat = convert_longlat(parts[0]);
    let lon = convert_longlat(parts[1]);
    format!("{},{}", lat, lon)
}

fn convert_longlat(value: &str) -> String {
    let (num, dir) = value.split_at(value.len() - 1);
    let val: f64 = num.parse().unwrap_or(0.0);
    let deg = (val / 100.0).floor();
    let min = val - deg * 100.0;
    let dec = deg + min / 60.0;
    let sign = match dir {
        "S" | "W" => -1.0,
        _ => 1.0,
    };
    format!("{:.5}", dec * sign)
}

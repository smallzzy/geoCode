function [result] = geoCode(address, service, key)
%GEOCODE look up the latitude and longitude of a an address
%
%   COORDS = GEOCODE( ADDRESS ) returns the geocoded latitude and longitude
%   of the input address.
%
%   COORDS = GEOCODE( ADDRESS, SERVICE) performs the look up using the
%   specified SERVICE. Valid services are
%       google  - Google Maps  (default service)
%       osm     - OpenStreetMap
%
%   COORDS = GEOCODE( ..., SERVICE, APIKEY) allows the specifcation of an
%   API key if needed.

% Copyright(c) 2012, Stuart P. Layton <stuart.layton@gmail.com>
% http://stuartlayton.com
%
% Revision History
%   2012/08/20 - Initial Release
%   2012/08/20 - Simplified XML parsing code
%   2016/08/19 - fix google v3

% Validate the input arguments

% Check to see if address is a valid string
if isempty(address) || ~ischar(address) || ~isvector(address)
    error('Invalid address provided, must be a string');
end

% if no service is specified or an empty service is specified use google
if nargin<2 || isempty(service)
    service = 'google';
end
service = lower(service);

% if no key is specified then set it to empty, also check to see if char array
if nargin<3
    key = [];
end

% replace white spaces in the address with '+'
address = regexprep(address, ' ', '+');

% Switch on the specified service, construct the Query URL, and specify the
% function that will be used to parse the resulting XML
switch service
    case('google')
        % google will determine limit based on ip if you do not provide key
        queryUrl = sprintf('https://maps.googleapis.com/maps/api/geocode/json?address=%s', address);
        
        % use key to determine based on key
        if ~isempty(key) || ischar(key) || isvector(key)
            queryUrl = sprintf('%s&key=%s', queryUrl, key);
        end

    case ('osm')
        % osm will limit use if no email is provided
        queryUrl = sprintf('http://nominatim.openstreetmap.org/search?format=json&q=%s', address);
        
        % add valid email to increase limit 
        if ~isempty(key) || ischar(key) || isvector(key)
            queryUrl = sprintf('%s&email=%s', queryUrl, key);
        end
        
        queryUrl = sprintf('%s&limit=%s', queryUrl, 1);
        
    case ('geonames')
                % osm will limit use if no email is provided
        queryUrl = sprintf('http://nominatim.openstreetmap.org/search?format=json&q=%s', address);
        
        % add valid email to increase limit 
        if ~isempty(key) || ischar(key) || isvector(key)
            queryUrl = sprintf('%s&email=%s', queryUrl, key);
        end
        
        queryUrl = sprintf('%s&limit=%s', queryUrl, 1);
        http://api.geonames.org/citiesJSON?north=44.1&south=-9.9&east=-22.4&west=55.2&lang=de&username=demo 

    otherwise
        error('Invalid geocoding service specified:%s', service);
end

% Switch on the specified service, choose different return type
switch service
    case('google')
        % read json file
        docNode = webread(queryUrl);
        % check status
        if ~strcmp(docNode.status,'OK');
            warning('receive data error: %s ', docNode.status);
            warning('location: %s\n', address);
            result = nan(2,1);
        else
            result = [docNode.results.geometry.location.lat, docNode.results.geometry.location.lng];
        end
        return;
        
    case ('osm')
        % check status
        try
            docNode = webread(queryUrl);
        catch ex
            disp(ex);
            error('receive data error')
        end
        % check if data is valid
        if isempty(docNode)
            warning('missing data at %s\n', address)
            result = nan(2,1);
        else
            result = [str2double(docNode.lat), str2double(docNode.lon)]; 
        end
        return;
end
end
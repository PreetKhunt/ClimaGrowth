'use client';

import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import { useEffect } from 'react';

// Fix for default marker icon in Leaflet + Next.js
const icon = L.icon({
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});

interface MapProps {
  center: [number, number];
  zoom?: number;
  onLocationSelect?: (lat: number, lng: number) => void;
  marker?: [number, number];
  readOnly?: boolean;
}

function LocationMarker({ onSelect, marker }: { onSelect?: (lat: number, lng: number) => void, marker?: [number, number] }) {
  useMapEvents({
    click(e) {
      if (onSelect) {
        onSelect(e.latlng.lat, e.latlng.lng);
      }
    },
  });

  return marker ? <Marker position={marker} icon={icon} /> : null;
}

export default function Map({ center, zoom = 13, onLocationSelect, marker, readOnly }: MapProps) {
  useEffect(() => {
    // Leaflet map container fix for some hydration issues
    setTimeout(() => {
      window.dispatchEvent(new Event('resize'));
    }, 200);
  }, []);

  return (
    <div style={{ height: '100%', width: '100%', minHeight: '300px', zIndex: 0 }}>
      <MapContainer 
        center={center} 
        zoom={zoom} 
        scrollWheelZoom={!readOnly}
        style={{ height: '100%', width: '100%', zIndex: 0 }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        <LocationMarker onSelect={!readOnly ? onLocationSelect : undefined} marker={marker} />
      </MapContainer>
    </div>
  );
}

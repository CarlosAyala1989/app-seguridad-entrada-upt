import { CameraView, useCameraPermissions } from 'expo-camera';
import { Button, SafeAreaView, StyleSheet, Text, View } from 'react-native';

export default function App() {
  const [permission, requestPermission] = useCameraPermissions();

  if (!permission) {
    return <View style={styles.center}><Text>Consultando permiso de cámara…</Text></View>;
  }
  if (!permission.granted) {
    return (
      <SafeAreaView style={styles.center}>
        <Text style={styles.message}>Se requiere la cámara para leer el QR.</Text>
        <Button title="Permitir cámara" onPress={requestPermission} />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <CameraView style={styles.camera} facing="back" />
      <Text style={styles.caption}>React Native · prueba de cámara operativa</Text>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000' },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24 },
  camera: { flex: 1 },
  caption: { color: '#fff', padding: 16, textAlign: 'center' },
  message: { marginBottom: 16, textAlign: 'center' },
});

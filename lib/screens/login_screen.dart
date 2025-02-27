import 'package:flutter/material.dart';
import 'package:titulos/components/componets_color.dart';
import 'package:titulos/screens/lista_bordero_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() {
    // Simula a navegação para a tela principal após login bem-sucedido
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ListaBorderosScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth >= 1024; // Web acima de 1024px

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  isWeb ? screenWidth * 0.3 : 24.0, // Web tem largura limitada
              vertical: 32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png',
                  height: isWeb ? 120 : 300, // Ajuste de tamanho no Web
                ),
                const SizedBox(height: 24),

                // Formulário
                _buildLoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Campo de E-mail
        _buildTextField(
          controller: _usernameController,
          label: 'Usuário',
          icon: Icons.person_2_sharp,
          obscureText: false,
        ),
        const SizedBox(height: 16),

        // Campo de Senha
        _buildTextField(
          controller: _passwordController,
          label: 'Senha',
          icon: Icons.lock,
          obscureText: _obscurePassword,
          isPassword: true,
          onTogglePassword: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: 24),

        // Botão de Login
        ElevatedButton(
          onPressed: _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFd7342f),
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 32.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'ENTRAR',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Esqueci minha senha
        TextButton(
          onPressed: () {
            // Implementar recuperação de senha futuramente
          },
          child: const Text(
            'Esqueci minha senha',
            style: TextStyle(
              color: Color(0xFFd7342f),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    bool isPassword = false,
    VoidCallback? onTogglePassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryColor),
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: primaryColor,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cardBackgroundColor, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

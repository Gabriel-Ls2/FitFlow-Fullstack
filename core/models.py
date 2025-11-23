from django.db import models
from django.contrib.auth.models import User

# 1. Modelo para as METAS (Tela: image_94f185.jpg)
# Armazena os objetivos do usuário (ex: 3000ml de água, 8h de sono)
class MetaDiaria(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    meta_agua_ml = models.IntegerField(default=3000, verbose_name="Meta de Água (ml)")
    meta_sono_horas = models.FloatField(default=8.0, verbose_name="Meta de Sono (horas)")
    meta_exercicio_min = models.IntegerField(default=60, verbose_name="Meta de Exercício (min)")
    meta_refeicoes_qtd = models.IntegerField(default=5, verbose_name="Meta de Refeições (qtd)")

    def __str__(self):
        return f"Metas de {self.user.username}"

# 2. Modelo para REGISTRO DE ÁGUA 
class RegistroAgua(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    quantidade_ml = models.IntegerField(verbose_name="Quantidade (ml)")
    data_criacao = models.DateTimeField(auto_now_add=True, verbose_name="Data do Registro")

    def __str__(self):
        return f"{self.quantidade_ml}ml em {self.data_criacao}"

# 3. Modelo para EXERCÍCIO 
class RegistroExercicio(models.Model):
    INTENSIDADE_CHOICES = [
        ('Baixa', 'Baixa'),
        ('Moderada', 'Moderada'),
        ('Intensa', 'Intensa'),
    ]
    
    ATIVIDADE_CHOICES = [
        ('Caminhada', 'Caminhada'),
        ('Corrida', 'Corrida'),
        ('Musculação', 'Musculação'),
        ('Natação', 'Natação'),
        ('Ciclismo', 'Ciclismo'),
        ('Outro', 'Outro'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    tipo_atividade = models.CharField(max_length=50, choices=ATIVIDADE_CHOICES, default='Outro')
    duracao_minutos = models.IntegerField(verbose_name="Duração (min)")
    intensidade = models.CharField(max_length=20, choices=INTENSIDADE_CHOICES, default='Moderada')
    data_criacao = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.tipo_atividade} - {self.duracao_minutos}min"

# 4. Modelo para SONO 
class RegistroSono(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    horas_sono = models.FloatField(verbose_name="Horas de Sono")
    data_registro = models.DateField(auto_now_add=True, verbose_name="Data do Sono")

    def __str__(self):
        return f"{self.horas_sono}h de sono"

# 5. Modelo para REFEIÇÃO
class RegistroRefeicao(models.Model):
    TIPO_REFEICAO_CHOICES = [
        ('Café da Manhã', 'Café da Manhã'),
        ('Almoço', 'Almoço'),
        ('Jantar', 'Jantar'),
        ('Lanche', 'Lanche'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    tipo_refeicao = models.CharField(max_length=50, choices=TIPO_REFEICAO_CHOICES)
    descricao = models.TextField(blank=True, null=True, verbose_name="O que você comeu?")
    data_criacao = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.tipo_refeicao}"

class PasswordResetCode(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.code}"
from django.shortcuts import render
from rest_framework import viewsets, permissions
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from django.utils import timezone
from django.db.models import Sum
from .models import MetaDiaria, RegistroAgua, RegistroExercicio, RegistroSono, RegistroRefeicao, PasswordResetCode
from .serializers import *
import random
from django.core.mail import send_mail
from rest_framework.permissions import AllowAny
from django.contrib.auth.models import User

class BaseViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated] 

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

# --- VIEWSETS ---

class MetaDiariaViewSet(BaseViewSet):
    queryset = MetaDiaria.objects.all()
    serializer_class = MetaDiariaSerializer

class RegistroAguaViewSet(BaseViewSet):
    queryset = RegistroAgua.objects.all().order_by('-data_criacao')
    serializer_class = RegistroAguaSerializer

class RegistroExercicioViewSet(BaseViewSet):
    queryset = RegistroExercicio.objects.all().order_by('-data_criacao')
    serializer_class = RegistroExercicioSerializer

class RegistroSonoViewSet(BaseViewSet):
    queryset = RegistroSono.objects.all().order_by('-data_registro')
    serializer_class = RegistroSonoSerializer

class RegistroRefeicaoViewSet(BaseViewSet):
    queryset = RegistroRefeicao.objects.all().order_by('-data_criacao')
    serializer_class = RegistroRefeicaoSerializer

# --- DASHBOARD API ---

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated]) 
def dashboard_data(request):
    user = request.user 
    hoje = timezone.now().date()
    
    # 1. Total de Água Hoje
    total_agua = RegistroAgua.objects.filter(user=user, data_criacao__date=hoje).aggregate(Sum('quantidade_ml'))['quantidade_ml__sum'] or 0
    
    # 2. Total de Exercício Hoje
    total_exercicio = RegistroExercicio.objects.filter(user=user, data_criacao__date=hoje).aggregate(Sum('duracao_minutos'))['duracao_minutos__sum'] or 0
    
    # 3. Sono (último registro)
    ultimo_sono = RegistroSono.objects.filter(user=user).first()
    horas_sono = ultimo_sono.horas_sono if ultimo_sono else 0

    # 4. Refeições Hoje
    total_refeicoes = RegistroRefeicao.objects.filter(user=user, data_criacao__date=hoje).count()
    
    return Response({
        "agua_hoje": total_agua,
        "exercicio_hoje": total_exercicio,
        "sono_hoje": horas_sono,
        "refeicoes_hoje": total_refeicoes
    })

from datetime import timedelta

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def progress_data(request):
    user = request.user
    hoje = timezone.now().date()
    
    # Vamos pegar os últimos 7 dias
    data_7_dias_atras = hoje - timedelta(days=6)
    
    # Listas para guardar os dados
    labels = [] # Ex: ["Seg", "Ter", ...]
    agua_data = []
    exercicio_data = []
    
    # Loop para percorrer cada dia da semana passada até hoje
    for i in range(7):
        dia = data_7_dias_atras + timedelta(days=i)
        
        # Cria o label (ex: "22/11")
        labels.append(dia.strftime("%d/%m"))
        
        # Soma Água do dia
        total_agua = RegistroAgua.objects.filter(user=user, data_criacao__date=dia).aggregate(Sum('quantidade_ml'))['quantidade_ml__sum'] or 0
        agua_data.append(total_agua)
        
        # Soma Exercício do dia
        total_exercicio = RegistroExercicio.objects.filter(user=user, data_criacao__date=dia).aggregate(Sum('duracao_minutos'))['duracao_minutos__sum'] or 0
        exercicio_data.append(total_exercicio)

    # Pegar histórico recente (lista de atividades)
    atividades_recentes = RegistroExercicio.objects.filter(user=user).order_by('-data_criacao')[:5]
    atividades_serialized = RegistroExercicioSerializer(atividades_recentes, many=True).data

    return Response({
        "labels": labels,
        "agua_semanal": agua_data,
        "exercicio_semanal": exercicio_data,
        "historico_atividades": atividades_serialized
    })

# --- SISTEMA DE RECUPERAÇÃO DE SENHA COM CÓDIGO (OTP) ---

@api_view(['POST'])
@permission_classes([AllowAny])
def solicitar_codigo_senha(request):
    email = request.data.get('email')
    
    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({"message": "Se o email existir, o código foi enviado."})

    codigo = str(random.randint(100000, 999999))

    PasswordResetCode.objects.filter(user=user).delete()
    PasswordResetCode.objects.create(user=user, code=codigo)

    send_mail(
        'Seu código de recuperação FitFlow',
        f'Seu código é: {codigo}',
        'webmaster@fitflow.com',
        [email],
        fail_silently=False,
    )

    return Response({"message": "Código enviado com sucesso!"})


@api_view(['POST'])
@permission_classes([AllowAny])
def verificar_codigo_e_mudar_senha(request):
    email = request.data.get('email')
    code = request.data.get('code')
    new_password = request.data.get('new_password')

    try:
        user = User.objects.get(email=email)
        reset_entry = PasswordResetCode.objects.filter(user=user, code=code).first()

        if reset_entry:
            user.set_password(new_password)
            user.save()

            reset_entry.delete()
            return Response({"message": "Senha alterada com sucesso!"})
        else:
            return Response({"error": "Código inválido ou expirado."}, status=400)

    except User.DoesNotExist:
        return Response({"error": "Usuário não encontrado."}, status=400)
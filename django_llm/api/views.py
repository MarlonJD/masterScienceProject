from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import permissions
from project.settings import BASE_DIR

# PyTorch model related imports
import torch
from transformers import GPT2LMHeadModel, GPT2Tokenizer


# Rest Framework Permissions
class IsLoggedInUserOrAdmin(permissions.BasePermission):
    """
    Permission class that allow user or admin to access
    """
    def has_permission(self, request, view):
        return (request.user.is_superuser or request.user.is_staff
                or request.user)

    def has_object_permission(self, request, view, obj):
        return (request.user or request.user.is_superuser
                or request.user.is_staff)


class AnswerPromt(APIView):
    permission_classes = [
        IsLoggedInUserOrAdmin,
    ]

    def post(self, request, *args, **kwargs):
        print(request.data)

        # parse json
        dataJson = request.data
        print(dataJson);
        
        try:
            prompt = dataJson['prompt']
        except:
            prompt = None
            return Response(data={"status": "error", "message": "prompt not found"})
        
        if prompt:
            # Model and tokenizer path
            model_path = f"{BASE_DIR}/model/math_gpt2.pt"
            tokenizer_path = f"{BASE_DIR}/model/math_gpt2_tokenizer"

            print(model_path)

            # Load tokenizer
            tokenizer = GPT2Tokenizer.from_pretrained(tokenizer_path)

            # Create model
            model = GPT2LMHeadModel.from_pretrained("gpt2")  # Model's architecture should be GPT-2
            model.load_state_dict(torch.load(model_path))

            inputs = tokenizer.encode(prompt, return_tensors='pt')
            outputs = model.generate(inputs, max_length=64, pad_token_id=tokenizer.eos_token_id)
            generated = tokenizer.decode(outputs[0], skip_special_tokens=True)
            return Response(data={"status": "success", "generated": generated[:generated.rfind(".")+1]})
package com.example.authapi.controller;

import com.example.authapi.dto.UserInfo;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @GetMapping("/info")
    public UserInfo getUserInfo(Authentication authentication) {
        Jwt jwt = (Jwt) authentication.getPrincipal();

        String username = jwt.getClaimAsString("preferred_username");
        String email = jwt.getClaimAsString("email");
        String name = jwt.getClaimAsString("name");

        List<String> roles = authentication.getAuthorities().stream()
            .map(GrantedAuthority::getAuthority)
            .map(auth -> auth.replace("ROLE_", ""))
            .collect(Collectors.toList());

        return new UserInfo(username, email, name, roles);
    }

    @GetMapping("/data")
    public Map<String, Object> getUserData(Authentication authentication) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "User-specific data");
        response.put("username", authentication.getName());
        response.put("timestamp", System.currentTimeMillis());

        Map<String, String> userData = new HashMap<>();
        userData.put("subscription", "Premium");
        userData.put("accountStatus", "Active");
        userData.put("joinDate", "2024-01-01");

        response.put("data", userData);
        return response;
    }
}

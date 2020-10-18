using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Controller : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void CallScene(string sceneName)
    {
        SceneManager.LoadScene(sceneName);      
    }

    public void Unload()
    {
        Application.Unload();
    }

}
